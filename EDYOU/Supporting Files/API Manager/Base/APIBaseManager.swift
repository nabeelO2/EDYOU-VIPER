//
//  HTTPManager.swift
//  EDYOU
//
//  Created by Zuhair Hussain on 03/09/2021.
//

import Foundation
import Bugsnag
import SwiftyJSON


enum CachePolicy {
    case useCacheOnly, useWebOnly, useBoth
}

enum RequestType: String {
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class APIBaseManager: NSObject {
    
    private var uploadProgress: ((_ progress: Float) -> Void)?
    
    func url(baseURL: String, route: String, parameters: [String: Any] = [:]) -> URL? {
        var queryParameters = ""
        for (key, value) in parameters {
            if queryParameters.isEmpty {
                queryParameters += "?\(key.trimmed)=\(value)".trimmed
            } else {
                queryParameters += "&\(key.trimmed)=\(value)".trimmed
            }
        }
        guard let urlString = (baseURL + route + queryParameters).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return URL(string: urlString)
    }
    
    func query(parameters: [String: Any]) -> String {
        var queryParameters = ""
        for (key, value) in parameters {
            if queryParameters.isEmpty {
                queryParameters += "\(key.trimmed)=\(value)".trimmed
            } else {
                queryParameters += "&\(key.trimmed)=\(value)".trimmed
            }
        }
        return queryParameters
    }
    func rawEncode(parameters: [String: Any]) -> String {
        var queryParameters = ""
        for (key, value) in parameters {
            if queryParameters.isEmpty {
                queryParameters += "\(key.trimmed):\(value)".trimmed
            } else {
                queryParameters += ", \(key.trimmed):\(value)".trimmed
            }
        }
        return queryParameters.count > 0 ? "{\(queryParameters)}" : ""
    }
    func fileName(url: URL, parameters: [String: Any]) -> String {
        let string = url.pathComponents.last ?? ""
        let name = string.replacingOccurrences(of: Constants.baseURL, with: "")
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: "?", with: "")
            .replacingOccurrences(of: "&", with: "")
        return "\(name)\(Cache.shared.user?.userID ?? "")".trimmed
    }
    
    
    
    func getRequest<T: Codable>(url: URL, header: [String: String], cachePolicy: CachePolicy = .useWebOnly, resultType: T.Type, completion: @escaping(_ result: T?, _ error: ErrorResponse?) -> Void) {

        if cachePolicy == .useCacheOnly {
            if let data = CacheManager.shared.read(fileName: fileName(url: url, parameters: [:])) {
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(result, nil)
                    return
                } catch {
                    print("[Cache Policy]: Invalid data type")
                }
            }
        } else if cachePolicy == .useBoth {
            if let data = CacheManager.shared.read(fileName: fileName(url: url, parameters: [:])) {
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(result, nil)
                } catch {
                    print("[Cache Policy]: Invalid data type")
                }
            }
        }
        
        
        var request = URLRequest(url: url)
        for (key, value) in header {
            request.setValue(value, forHTTPHeaderField: key)
        }
                
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            DispatchQueue.main.async {
                if let data = data {
                    
                    #if DEBUG
//                    if let dataString = String(data: data, encoding: .utf8) {
//                        print(dataString)
//                    }
                    
                    if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                        print("[REQUEST] url: \(url.absoluteString)")
                        print("header: \(header)")
                        print(jsonResponse)
                    } else if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [NSDictionary] {
                        print("[REQUEST] url: \(url.absoluteString)")
                        print(jsonResponse)
                    }
                    #endif
                    
                    
                    let code = (response as? HTTPURLResponse)?.statusCode
                    do {
                        if code == 200 {
                           
                            let result = try JSONDecoder().decode(T.self, from: data)
                           
                            //CacheManager.shared.write(data: data, fileName: self.fileName(url: url, parameters: [:]))
                            
                            completion(result, nil)
                        }else{
                            self.isSessionExpire(code: code ?? 0)
                            let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            completion(nil, error)
                        }
                        
                    }
                    
                    catch {
                        
                        if T.self == Events.self{
                            
                            do {
                                let dataaa = try JSON(data : data)
                                print(dataaa)
                                if let result = Events.build(json: dataaa) as? T{
                                    print(result)
                                    completion(result, nil)
                                    return
                                }
                            }
                            catch{
                                if let dataString = String(data: data, encoding: .utf8) {
                                    
                                    let error = ErrorResponse(detail: [ErrorResponseDetail(msg: dataString, type:  "", loc: [])])
                                    completion(nil, error)
                                    
                                }
                                
                                
                            }
                            
                        }
                        else if T.self == MyEvents.self{
                            do {
                                let dataaa = try JSON(data : data)
                                print(dataaa)
                                if let result = MyEvents.build(dataaa) as? T{
                                    print(result)
                                    completion(result, nil)
                                    return
                                }
                            }
                            catch{
                                if let dataString = String(data: data, encoding: .utf8) {
                                    
                                    let error = ErrorResponse(detail: [ErrorResponseDetail(msg: dataString, type:  "", loc: [])])
                                    completion(nil, error)
                                    
                                }
                                
                                
                            }
                            return
                           
                            
                        }
                        
//                        if let dataString = String(data: data, encoding: .utf8) {
//                            print(dataString)
//                        }
                        
                        
                        print(error)
                        
                        Bugsnag.notifyError(error)
                    
                        if code == 504{
                            if let dataString = String(data: data, encoding: .utf8) {
                                print(dataString)
                                completion(nil,  ErrorResponse(detail: [ErrorResponseDetail(msg: dataString, type:  "", loc: [])]))
                            }
                            
                        }
                        else{
                            
                            
//                            completion(nil, ErrorResponse.parsingFailed)
                            
                            
                        }
                        
                       // let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        
                    }
                                    } else {
                    completion(nil,nil)
                }
            }        
            
        }

        task.resume()
    }
    
    func requestData<T: Codable>(url: URL, method: RequestType, header: [String: String], parameters: Data, parameterType: ParameterType = .httpUrlEncode, resultType: T.Type, completion: @escaping(_ result: T?, _ error: ErrorResponse?) -> Void) {

        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        for (key, value) in header {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if parameterType == .raw {
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            var httpBody = Data()
            do {
                httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                let jsonString = String(data: httpBody, encoding: .utf8) ?? ""
                print("[\(#function)]: JSON STRING PARAMATERS : \(jsonString)")
            } catch {
                print("[\(#function)]: parameter serialization error: \(error.localizedDescription)")
            }
            request.httpBody = httpBody
            
            
        } else {
            let httpBody = parameters
            request.httpBody = httpBody
        }
        
        
        request.httpMethod = method.rawValue
        
                
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            DispatchQueue.main.async {
                if let data = data {
                    
                    #if DEBUG
                    if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                        print("[REQUEST] url: \(url.absoluteString)")
                        print("[REQUEST]: parameters: \(parameters)")
                        print(jsonResponse)
                    } else if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [NSDictionary] {
                        print("[REQUEST] url: \(url.absoluteString)")
                        print("[REQUEST]: parameters: \(parameters)")
                        print(jsonResponse)
                    }
                    #endif
                    
                    let code = (response as? HTTPURLResponse)?.statusCode
                    do {
                        
                        if code == 200 {
                            let result = try JSONDecoder().decode(T.self, from: data)
                            completion(result, nil)
                        } else {
                            self.isSessionExpire(code: code ?? 0)
                            let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            completion(nil, error)
                        }
                    }
                    catch {
                       
                        Bugsnag.notifyError(error)
                   
                        print(error)
//                        completion(nil, ErrorResponse.parsingFailed)
                    }
                    
                } else {
                    completion(nil, ErrorResponse.emptyResponse)
                }
            }
            
        }

        task.resume()
    }
    
    
    func postRequest<T: Codable>(url: URL, header: [String: String], parameters: [String: Any], parameterType: ParameterType = .httpUrlEncode, resultType: T.Type, completion: @escaping(_ result: T?, _ error: ErrorResponse?) -> Void) {

        
        var request = URLRequest(url: url, timeoutInterval: 20)
        for (key, value) in header {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if parameterType == .raw {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            var httpBody = Data()
            do {
                httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                let jsonString = String(data: httpBody, encoding: .utf8) ?? ""
                print("[\(#function)]: JSON STRING PARAMATERS : \(jsonString)")
            } catch {
                print("[\(#function)]: parameter serialization error: \(error.localizedDescription)")
            }
            request.httpBody = httpBody
            
            
        } else {
            let p = query(parameters: parameters as [String : Any]).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            let httpBody = p.data(using: .utf8)
            request.httpBody = httpBody
        }
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            DispatchQueue.main.async {
                if let data = data {
                    
                    #if DEBUG
                    if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                        print("[REQUEST] url: \(url.absoluteString)")
                        print("[REQUEST]: parameters: \(parameters)")
                        print("[REQUEST]: header: \(header)")

                        print(jsonResponse)
                    } else if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [NSDictionary] {
                        print("[REQUEST] url: \(url.absoluteString)")
                        print("[REQUEST]: parameters: \(parameters)")
                        print("[REQUEST]: header: \(header)")
                        print(jsonResponse)
                    }
                    #endif
                    
                    let code = (response as? HTTPURLResponse)?.statusCode
                    do {
                        
                        if code == 200 {
                            let result = try JSONDecoder().decode(T.self, from: data)
                            completion(result, nil)
                        } else {
                            let string = String(data: data, encoding: .utf8)
                            print(string)
                            self.isSessionExpire(code: code ?? 0)
                            let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            completion(nil, error)
                        }
                    }
                    catch {
                       
                        Bugsnag.notifyError(error)
                    
                        print("❌❌❌❌❌❌\(error)❌❌❌❌❌❌")
//                        completion(nil, ErrorResponse.parsingFailed)
                    }
                    
                } else {
                    
                    if let error = error{
                        Bugsnag.notifyError(error)
                    }
                    completion(nil, ErrorResponse.emptyResponse)
                }
            }
            
        }

        task.resume()
    }
    
    
    func putRequest<T: Codable>(url: URL, header: [String: String], parameters: [String: Any], parameterType: ParameterType = .httpUrlEncode, resultType: T.Type, completion: @escaping(_ result: T?, _ error: ErrorResponse?) -> Void) {

        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        for (key, value) in header {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        var httpBody = Data()
        do {
            httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
           
            let theJSONText = NSString(data: httpBody,
              encoding: NSASCIIStringEncoding)
            print("JSON string = \(theJSONText!)")

        } catch {
            print("[\(#function)]: parameter serialization error: \(error.localizedDescription)")
        }
        request.httpBody = httpBody
        
//        if parameterType == .raw {
//
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            var httpBody = Data()
//            do {
//                httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
//            } catch {
//                print("[\(#function)]: parameter serialization error: \(error.localizedDescription)")
//            }
//            request.httpBody = httpBody
//
//
//        } else {
//            let p = query(parameters: parameters).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
//            let httpBody = p.data(using: .utf8)
//            request.httpBody = httpBody
//        }
        
        request.httpMethod = "PUT"
        
          
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            DispatchQueue.main.async {
                if let data = data {
                    
                    #if DEBUG
                    if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                        print("[REQUEST] url: \(url.absoluteString)")
                        print("[REQUEST]: parameters: \(parameters)")
                        print("[REQUEST]: header: \(header)")
                        print(jsonResponse)
                    } else if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [NSDictionary] {
                        print("[REQUEST] url: \(url.absoluteString)")
                        print("[REQUEST]: parameters: \(parameters)")
                        print("[REQUEST]: header: \(header)")
                        print(jsonResponse)
                    }
                    #endif
                    
                    let code = (response as? HTTPURLResponse)?.statusCode
                    do {
                        
                        if code == 200 {
                            let result = try JSONDecoder().decode(T.self, from: data)
                            completion(result, nil)
                        } else {
                            self.isSessionExpire(code: code ?? 0)
                            let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            completion(nil, error)
                        }
                    }
                    catch {
                      
                        Bugsnag.notifyError(error)
                    
                        print(error)
//                        completion(nil, ErrorResponse.parsingFailed)
                    }
                    
                } else {
                    if let error = error{
                        Bugsnag.notifyError(error)
                    }
                    
                    completion(nil, ErrorResponse.emptyResponse)
                }
            }
            
        }

        task.resume()
    }
    func deleteRequest<T: Codable>(url: URL, header: [String: String], parameters: [String: Any], resultType: T.Type, completion: @escaping(_ result: T?, _ error: ErrorResponse?) -> Void) {

        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        for (key, value) in header {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        
        var httpBody = Data()
        do {
            httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            print("[\(#function)]: parameter serialization error: \(error.localizedDescription)")
        }
        request.httpBody = httpBody
        request.httpMethod = "DELETE"
        
                
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            DispatchQueue.main.async {
                if let data = data {
                    
                    #if DEBUG
                    if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                        print("[REQUEST] url: \(url.absoluteString)")
                        print("[REQUEST]: parameters: \(parameters)")
                        print("header: \(header)")

                        print(jsonResponse)
                    } else if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [NSDictionary] {
                        print("[REQUEST] url: \(url.absoluteString)")
                        print("[REQUEST]: parameters: \(parameters)")
                        print("header: \(header)")

                        print(jsonResponse)
                    }
                    #endif
                    
                    let code = (response as? HTTPURLResponse)?.statusCode
                    do {
                        
                        if code == 200 {
                            let result = try JSONDecoder().decode(T.self, from: data)
                            completion(result, nil)
                        } else {
                            self.isSessionExpire(code: code ?? 0)
                            let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            completion(nil, error)
                        }
                    }
                    catch {
                       
                        Bugsnag.notifyError(error)
                    
                        print(error)
//                        completion(nil, ErrorResponse.parsingFailed)
                    }
                    
                } else {
                    if let error = error{
                        Bugsnag.notifyError(error)
                    }
                    completion(nil, ErrorResponse.emptyResponse)
                }
            }
            
        }

        task.resume()
    }
    
    func upload<T: Codable>(url:URL, requestType: HTTPMethod,  headers:[String: String], parameters: [String:Any], media: [Media], resultType: T.Type, progress: ((_ progress: Float) -> Void)?, completion: @escaping(_ result: T?, _ error: ErrorResponse?) -> Void) {
        
        self.uploadProgress = progress
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        var request = URLRequest(url: url)
        request.httpMethod = requestType.rawValue
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
//        let loginString = "admin:admin"
//
//        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
//            return
//        }
//        let base64LoginString = loginData.base64EncodedString()
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        var requestData = Data()
        for(key, value) in parameters {
            // Add the reqtype field and its value to the raw http request data
            if let array = value as? [String] {
                for item in array {
                    requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                    requestData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                    requestData.append("\(item)".data(using: .utf8)!)
                }
            } else {
                requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                requestData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                requestData.append("\(value)".data(using: .utf8)!)
            }
        }
        for m in media {
            // Add the image data to the raw http request data
            if let data = m.data {
                requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                requestData.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(m.filename)\"\r\n".data(using: .utf8)!)
                requestData.append("Content-Type: \(m.mimeType)\r\n\r\n".data(using: .utf8)!)
                requestData.append(data)
            }
        }
        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        requestData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: request, from: requestData, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    
                    #if DEBUG
//                    if let dataString = String(data: data, encoding: .utf8) {
//                        print(dataString)
//                    }
                    
                    if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                        print("[REQUEST] url: \(url.absoluteString)")
                        print("[REQUEST]: parameters: \(parameters)")
                        print(jsonResponse)
                    } else if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [NSDictionary] {
                        print("[REQUEST] url: \(url.absoluteString)")
                        print("[REQUEST]: parameters: \(parameters)")
                        print(jsonResponse)
                    }
                    #endif
                    
                    let code = (response as? HTTPURLResponse)?.statusCode
                    do {
                        if code == 200 {
                            let result = try JSONDecoder().decode(T.self, from: data)
                            completion(result, nil)
                        } else {
                            self.isSessionExpire(code: code ?? 0)
                            let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            completion(nil, error)
                        }
                    }
                    catch {
                       
                        Bugsnag.notifyError(error)
                    
                        print(error)
                        completion(nil, ErrorResponse.parsingFailed)
                    }
                    
                } else {
                    if let error = error{
                        Bugsnag.notifyError(error)
                    }
                    completion(nil, ErrorResponse.emptyResponse)
                }
            }
            
        }).resume()
    }

    
    
    func upload<T: Codable>(url:URL, requestType: HTTPMethod,  headers:[String: String], media: [Media], resultType: T.Type, progress: ((_ progress: Float) -> Void)?, completion: @escaping(_ result: T?, _ error: ErrorResponse?) -> Void) {
        
        self.uploadProgress = progress
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        var request = URLRequest(url: url)
        request.httpMethod = requestType.rawValue
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var requestData = Data()
   
        for m in media {
            // Add the image data to the raw http request data
            if let data = m.data {
                requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                requestData.append("Content-Disposition: form-data; name=\"\(m.key)\"; filename=\"\(m.filename)\"\r\n".data(using: .utf8)!)
                requestData.append("Content-Type: \(m.mimeType)\r\n\r\n".data(using: .utf8)!)
                requestData.append(data)
            }
        }
        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        requestData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: request, from: requestData, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    
                    #if DEBUG
                    if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                        print("[REQUEST] url: \(url.absoluteString)")
                    
                        print(jsonResponse)
                    } else if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [NSDictionary] {
                        print("[REQUEST] url: \(url.absoluteString)")
                       
                        print(jsonResponse)
                    }
                    #endif
                    
                    let code = (response as? HTTPURLResponse)?.statusCode
                    do {
                        
                        if code == 200 {
                            let result = try JSONDecoder().decode(T.self, from: data)
                            completion(result, nil)
                        } else {
                            self.isSessionExpire(code: code ?? 0)
                            let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            completion(nil, error)
                        }
                    }
                    catch {
                        
                        Bugsnag.notifyError(error)
                    
                        print(error)
//                        completion(nil, ErrorResponse.parsingFailed)
                    }
                    
                } else {
                    if let error = error{
                        Bugsnag.notifyError(error)
                    }
                    completion(nil, ErrorResponse.emptyResponse)
                }
            }
            
            
        }).resume()
    }
    
    func isSessionExpire(code: Int){
        if code ==  401 && APIManager.shared.loginRetryCount < APIManager.loginRetryLimit{
            APIManager.shared.loginRetryCount += 1
            APIManager.auth.refreshToken { error in
                
            }
        }
    }

}


extension APIBaseManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        self.uploadProgress?(progress)
    }
}
