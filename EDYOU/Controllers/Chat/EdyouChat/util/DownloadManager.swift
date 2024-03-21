//
// DownloadManager.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import Foundation
import MobileCoreServices
import Martin
import Shared

class DownloadManager: NSObject {
    
    static let instance = DownloadManager();
    
    private let dispatcher = QueueDispatcher(label: "download_manager_queue");
    
    private var itemDownloadInProgress: [Int] = [];
    
    private var downloadSession: URLSession!;
    
    private var inProgress: [URLSessionDownloadTask: Item] = [:];
    
    private override init() {
        super.init();
        downloadSession = URLSession(configuration: URLSession.shared.configuration, delegate: self, delegateQueue: nil);
    }
    
    func downloadInProgress(for item: ConversationEntry) -> Bool {
        return dispatcher.sync {
            return self.itemDownloadInProgress.contains(item.id);
        }
    }
    
    func download(item: ConversationEntry, url inUrl: String, maxSize: Int64) -> Bool {
        return dispatcher.sync {
            guard var url = URL(string: inUrl) else {
                DBChatHistoryStore.instance.updateItem(for: item.conversation, id: item.id, updateAppendix: { appendix in
                    appendix.state = .error;
                });
                return false;
            }
            
            guard !itemDownloadInProgress.contains(item.id) else {
                return false;
            }
            
            itemDownloadInProgress.append(item.id);
            
            if let hash = Digest.sha1.digest(toHex: inUrl.data(using: .utf8)!), var params = SettingsStore.sharedDefaults.dictionary(forKey: "upload-\(hash)"), let filename = params["name"] as? String {
                var jids: [BareJID] = (params["jids"] as? [String])?.map({ BareJID($0) }) ?? [];

                let sharedFileUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.edyou.shared")!.appendingPathComponent("upload", isDirectory: true).appendingPathComponent(hash, isDirectory: false);

                var handled = false;
                if jids.contains(item.conversation.jid) {
                    jids = jids.filter({ (j) -> Bool in
                        return j != item.conversation.jid;
                    });
                    params["jids"] = jids.map({ $0.stringValue });
                    
                    _ = DownloadStore.instance.store(sharedFileUrl, filename: filename, with: "\(item.id)");
                    DBChatHistoryStore.instance.updateItem(for: item.conversation, id: item.id, updateAppendix: { appendix in
                        appendix.filesize = params["size"] as? Int;
                        appendix.mimetype = params["mimeType"] as? String;
                        appendix.filename = filename;
                        appendix.state = .downloaded;
                    });
                    handled = true;
                }
                
                if jids.isEmpty || !FileManager.default.fileExists(atPath: sharedFileUrl.path) {
                    SettingsStore.sharedDefaults.removeObject(forKey: "upload-\(hash)")
                    if FileManager.default.fileExists(atPath: sharedFileUrl.path) {
                        try! FileManager.default.removeItem(at: sharedFileUrl);
                    }
                } else {
                    SettingsStore.sharedDefaults.set(params, forKey: "upload-\(hash)");
                }
                guard !handled else {
                    self.itemDownloadInProgress = self.itemDownloadInProgress.filter({ (id) -> Bool in
                        return item.id != id;
                    });
                    return true;
                }
            }
            
            var encryptionKey: String? = nil;
            if url.scheme == "aesgcm", var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                encryptionKey = components.fragment;
                components.scheme = "https";
                components.fragment = nil;
                if let tmpUrl = components.url {
                    url = tmpUrl;
                }
            }
            
            retrieveHeaders(session: downloadSession, url: url, completionHandler: { headersResult in
                switch headersResult {
                case .success(let suggestedFilename, let expectedSize, let mimeType):
                    let isTooBig = expectedSize > maxSize;
                    
                    DBChatHistoryStore.instance.updateItem(for: item.conversation, id: item.id, updateAppendix: { appendix in
                        appendix.filesize = Int(expectedSize);
                        appendix.mimetype = mimeType;
                        appendix.filename = suggestedFilename;
                        if isTooBig {
                            appendix.state = .tooBig;
                        }
                    });
                    
                    guard !isTooBig else {
                        self.dispatcher.async {
                            self.itemDownloadInProgress = self.itemDownloadInProgress.filter({ (id) -> Bool in
                                return item.id != id;
                            });
                        }
                        return;
                    }
                                        
                    self.download(session: self.downloadSession, url: url, expectedSize: expectedSize, completionHandler: { result in
                        switch result {
                        case .success((let downloadedUrl, let filename)):
                            var dataConsumer: Cipher.TempFileConsumer?;
                            if let encryptionKey = encryptionKey, let inputStream = InputStream(url: downloadedUrl), encryptionKey.count % 2 == 0 && encryptionKey.count > 64, let size = try? downloadedUrl.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                                
                                let fragmentData = encryptionKey.map { (c) -> UInt8 in
                                    return UInt8(c.hexDigitValue ?? 0);
                                };

                                let ivLen = fragmentData.count - (32 * 2);
                                var iv = Data();
                                var key = Data();
                                
                                for i in 0..<(ivLen/2) {
                                    iv.append(fragmentData[i*2]*16 + fragmentData[i*2+1]);
                                }
                                for i in (ivLen/2)..<(fragmentData.count/2) {
                                    key.append(fragmentData[i*2]*16 + fragmentData[i*2+1]);
                                }
                                
                                let dataProvider = Cipher.FileDataProvider(inputStream: inputStream, fileSize: size, hasAuthTag: true);
                                dataConsumer = Cipher.TempFileConsumer();
                                let aes = Cipher.AES_GCM();
                                                                
                                if !aes.decrypt(iv: iv, key: key, provider: dataProvider, consumer: dataConsumer!) {
                                    dataConsumer = nil;
                                }
                                dataConsumer?.close();
                            }
                            //let id = UUID().uuidString;
                            _ = DownloadStore.instance.store(dataConsumer?.url ?? downloadedUrl, filename: filename, with: "\(item.id)");
                            DBChatHistoryStore.instance.updateItem(for: item.conversation, id: item.id, updateAppendix: { appendix in
                                appendix.state = .downloaded;
                            });
                            self.dispatcher.sync {
                                self.itemDownloadInProgress = self.itemDownloadInProgress.filter({ (id) -> Bool in
                                    return item.id != id;
                                });
                            }
                        case .failure(let err):
                            var statusCode = 0;
                            switch err {
                            case .fileSizeMismatch:
                                statusCode = 404;
                            case .responseError(let code):
                                statusCode = code;
                            default:
                                break;
                            }
                            DBChatHistoryStore.instance.updateItem(for: item.conversation, id: item.id, updateAppendix: { appendix in
                                appendix.state = statusCode == 404 ? .gone : .error;
                            });
                            self.dispatcher.sync {
                                self.itemDownloadInProgress = self.itemDownloadInProgress.filter({ (id) -> Bool in
                                    return item.id != id;
                                });
                            }
                        }
                    });
                    break;
                case .failure(let statusCode):
                    DBChatHistoryStore.instance.updateItem(for: item.conversation, id: item.id, updateAppendix: { appendix in
                        appendix.state = statusCode == 404 ? .gone : .error;
                    });
                    self.dispatcher.async {
                        self.itemDownloadInProgress = self.itemDownloadInProgress.filter({ (id) -> Bool in
                            return item.id != id;
                        });
                    }
                }
            })
            return true;
        }
    }
    
    func download(session: URLSession, url: URL, expectedSize: Int64, completionHandler: @escaping (Result<(URL,String), DownloadError>)->Void) {
        let request = URLRequest(url: url);
        let task = session.downloadTask(with: request);
        inProgress[task] = Item(maxSize: expectedSize, completionHandler: completionHandler);
        task.resume();
    }
    
    static func mimeTypeToExtension(mimeType: String) -> String? {
        let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)
        guard let fileUTI = uti?.takeRetainedValue(),
            let fileExtension = UTTypeCopyPreferredTagWithClass(fileUTI, kUTTagClassFilenameExtension) else { return nil }

        let extensionString = String(fileExtension.takeRetainedValue())
        return extensionString
    }
    
    func retrieveHeaders(session: URLSession, url: URL, completionHandler: @escaping (HeadersResult)->Void) {
        var request = URLRequest(url: url);
        request.httpMethod = "HEAD";
        session.dataTask(with: request) { (data, resp, error) in
            guard let response = resp as? HTTPURLResponse else {
                completionHandler(.failure(statusCode: 500));
                return;
            }
            
            switch response.statusCode {
            case 200:
                completionHandler(.success(suggestedFilename: response.suggestedFilename, expectedSize: response.expectedContentLength, mimeType: response.mimeType))
            default:
                completionHandler(.failure(statusCode: response.statusCode));
            }
        }.resume();
    }
    
    class Item {
        let maxSize: Int64;
        let completionHandler: (Result<(URL,String), DownloadError>)->Void;
        init(maxSize: Int64, completionHandler: @escaping (Result<(URL,String), DownloadError>)->Void) {
            self.completionHandler = completionHandler;
            self.maxSize = maxSize;
        }

        func completed(location: URL, filename: String) {
            completionHandler(.success((location, filename)));
        }
        
        func completed(withError error: Error?) {
            guard let err = error else {
                completionHandler(.failure(.responseError(statusCode: 500)));
                return;
            }
            if (err as NSError).domain == "NSURLErrorDomain" && (err as NSError).code == NSURLErrorCancelled {
                completionHandler(.failure(.fileSizeMismatch));
            } else {
                completionHandler(.failure(.networkError(error: err)));
            }
        }

    }
    
    enum HeadersResult {
        case success(suggestedFilename: String?, expectedSize: Int64, mimeType: String?)
        case failure(statusCode: Int)
    }
        
    enum DownloadError: Error {
        case networkError(error: Error)
        case responseError(statusCode: Int)
        case tooBig(size: Int64, mimeType: String?, filename: String?)
        case badMimeType(mimeType: String?)
        case fileSizeMismatch
    }
    
}

extension DownloadManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let item = dispatcher.sync(execute: {
            return self.inProgress.removeValue(forKey: downloadTask);
        }) else {
            return;
        }
        
        if let filename = downloadTask.response?.suggestedFilename {
            item.completed(location: location, filename: filename);
        } else if let mimeType = downloadTask.response?.mimeType, let filenameExt = DownloadManager.mimeTypeToExtension(mimeType: mimeType) {
            item.completed(location: location, filename: "file.\(filenameExt)");
        } else if let uti = try? location.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier, let filenameExt = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue() as String? {
            item.completed(location: location, filename: "file.\(filenameExt)");
        } else {
            item.completed(location: location, filename: location.lastPathComponent);
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? URLSessionDownloadTask, let item = dispatcher.sync(execute: {
            return self.inProgress.removeValue(forKey: downloadTask);
        }) else {
            return;
        }
        item.completed(withError: error);
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let sizeLimit = dispatcher.sync(execute: {
            return self.inProgress[downloadTask]?.maxSize;
        }) else {
            return;
        }

        if (sizeLimit != NSURLSessionTransferSizeUnknown) {
            if ((totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown && totalBytesExpectedToWrite > sizeLimit + 32) || sizeLimit + 32 < totalBytesWritten) {
                downloadTask.cancel();
            }
        }
    }
}
