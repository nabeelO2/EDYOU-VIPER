//
// ChatTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


import UIKit
import Martin

class ChatTableViewCell: BaseChatTableViewCell, UITextViewDelegate {

    @IBOutlet var messageTextView: MessageTextView!
    @IBOutlet var messageBubbleView: UIView!
    @IBOutlet var sendingStampImgV: UIImageView!
    
    var id: Int = 0;
    
    override var backgroundColor: UIColor? {
        didSet {
        }
    }
        
    func setRetracted(item: ConversationEntry) {
        set(item: item);
        
        
        let msg = NSAttributedString(string: NSLocalizedString("(this message has been removed)", comment: "conversation log label"), attributes: [.font: UIFont.systemFont(ofSize: 17), .foregroundColor: messageTextView.tintColor ?? .black]);
        
       // let str = NSLocalizedString("(this message has been removed)", comment: "conversation")
                                         
        
        self.messageTextView.attributedText = msg
    }
    
    override func set(item: ConversationEntry) {
        super.set(item: item);
        id = item.id;
    }
    
    func set(item: ConversationEntry, message inMessage: String, correctionTimestamp: Date?, nickname: String? = nil) {
        messageTextView.textView.delegate = self;
        set(item: item);
        
        let accessibilityLabel = NSMutableAttributedString(string: "")
        if let nickname = self.nicknameView?.text {
            accessibilityLabel.append(NSAttributedString(string: "\(nickname)"))
        }
        if let timestamp = self.timestampView?.text {
            accessibilityLabel.append(NSAttributedString(string: " \(timestamp)"))
        }
        
        if correctionTimestamp != nil, case .incoming(_) = item.state {
            self.stateView?.text = "✏️\(self.stateView!.text ?? "")";
        }
       
        let message = messageBody(item: item, message: inMessage);
        let attrText = NSMutableAttributedString(string: message);
        
            
        if let detect = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue | NSTextCheckingResult.CheckingType.phoneNumber.rawValue | NSTextCheckingResult.CheckingType.address.rawValue | NSTextCheckingResult.CheckingType.date.rawValue) {
            let matches = detect.matches(in: message, options: .reportCompletion, range: NSMakeRange(0, message.count));
            for match in matches {
                var url: URL? = nil;
                if match.url != nil {
                    url = match.url;
                }
                if match.phoneNumber != nil {
                    url = URL(string: "tel:\(match.phoneNumber!.replacingOccurrences(of: " ", with: "-"))");
                }
                if match.addressComponents != nil {
                    if let query = match.addressComponents!.values.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                        url = URL(string: "http://maps.apple.com/?q=\(query)");
                    }
                }
                if match.date != nil {
                    url = URL(string: "calshow:\(match.date!.timeIntervalSinceReferenceDate)");
                }
                if let url = url {
                    attrText.setAttributes([.link : url], range: match.range);
                }
            }
        }
        attrText.addAttribute(.foregroundColor, value: messageTextView.tintColor as Any, range: NSRange(location: 0, length: attrText.length));
        if Settings.enableMarkdownFormatting {
            Markdown.applyStyling(attributedString: attrText, defTextStyle: .body, showEmoticons: Settings.showEmoticons);
        } else {
            attrText.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .subheadline), range: NSRange(location: 0, length: attrText.length));
            attrText.fixAttributes(in: NSRange(location: 0, length: attrText.length));

        }
        self.messageTextView.attributedText = attrText;
        
        if accessibilityLabel.length > 0 {
            accessibilityLabel.append(NSAttributedString(string: " "));
        }
        accessibilityLabel.append(attrText);
        
        self.accessibilityAttributedLabel = accessibilityLabel;
        self.isAccessibilityElement = true

       
        
//        if item.state.isError {
//            if (self.messageTextView.text?.isEmpty ?? true), let error = item.error {
//                self.messageTextView.text = "Error: \(error)";
//            }
//            if item.state.direction == .incoming {
//                self.messageTextView.textView.textColor = UIColor.red;
//            }
//        } else {
//            if item.encryption == .notForThisDevice || item.encryption == .decryptionFailed {
//                self.messageTextView.textView.textColor = UIColor(named: "chatMessageText");
//            }
//        }
    }
    
    func setStampImg(_ code : Int){
        if sendingStampImgV == nil {
            return
        }
        
        switch code{
        case 1:// outgoing sent
            sendingStampImgV.image = UIImage(named: "sentTicks")
            break
            
        case 3://outgoing unsent
            sendingStampImgV.image = UIImage(named: "sendingStamp")
            break
            
        case 5://outgoing error displayed
            sendingStampImgV.image = UIImage(named: "sendingStamp")
            break
        case 7://outgoing error received
            sendingStampImgV.image = UIImage(named: "sendingStamp")
            break
        case 9://outgoing delivered
            sendingStampImgV.image = UIImage(named: "deliveredTicks")
            break
        case 11://outgoing displayed
            sendingStampImgV.image = UIImage(named: "seenTick")
            break
        default:
            sendingStampImgV.image = nil
            break
        }
        
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL);
        return false;
    }
    
    fileprivate func messageBody(item: ConversationEntry, message: String) -> String {
        guard let msg = item.options.encryption.message() else {
            switch item.state {
            case .incoming_error(_, let errorMessage), .outgoing_error(_, let errorMessage):
                if let error = errorMessage {
                    return "\(message)\n-----\n\(error)"
                }
            default:
                break;
            }
            return message;
        }
        return msg;
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromOptionalNSTextCheckingKeyDictionary(_ input: [NSTextCheckingKey: Any]?) -> [String: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
