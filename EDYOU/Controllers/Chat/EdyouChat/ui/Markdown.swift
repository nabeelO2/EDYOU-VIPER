//
// Markdown.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import TigaseLogging

extension unichar: ExpressibleByUnicodeScalarLiteral {
    public typealias UnicodeScalarLiteralType = UnicodeScalar
    
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self.init(value.value);
    }
}

class Markdown {
    
    static let quoteParagraphStyle: NSParagraphStyle = {
        var paragraphStyle = NSMutableParagraphStyle();
        paragraphStyle.headIndent = 16;
        paragraphStyle.firstLineHeadIndent = 4;
        paragraphStyle.alignment = .natural;
        return paragraphStyle;
    }();
    
    static let codeParagraphStyle: NSParagraphStyle = {
        var paragraphStyle = NSMutableParagraphStyle();
        paragraphStyle.headIndent = 10;
        paragraphStyle.tailIndent = -10;
        paragraphStyle.firstLineHeadIndent = 10;
        paragraphStyle.alignment = .natural;
        return paragraphStyle;
    }();
    
    static func font(withTextStyle textStyle: UIFont.TextStyle, andTraits traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let preferredFont = UIFont.preferredFont(forTextStyle: textStyle);
        let fontDescription = preferredFont.fontDescriptor.withSymbolicTraits(traits)!;
        let newFont = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: UIFont(descriptor: fontDescription, size: preferredFont.pointSize - 1));
        return newFont;
    }
    
    static func code(withTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        let preferredFont = UIFont.preferredFont(forTextStyle: textStyle);
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: UIFont(descriptor: preferredFont.fontDescriptor.withDesign(.monospaced)!, size: preferredFont.fontDescriptor.pointSize - 1));
    }
    
    static let NEW_LINE: unichar = "\n";
    static let GT_SIGN: unichar = ">";
    static let SPACE: unichar = " ";
    static let ASTERISK: unichar = "*";
    static let UNDERSCORE: unichar = "_";
    static let GRAVE_ACCENT: unichar = "`";
    static let CR_SIGN: unichar = "\r";
    
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Markdown");
    
    static func applyStyling(attributedString msg: NSMutableAttributedString, defTextStyle: UIFont.TextStyle, showEmoticons: Bool) {
        let stylingColor = UIColor(named: "sub_title")!;
        var message = msg.string as NSString;
        
        var boldStart: Int? = nil;
        var italicStart: Int? = nil;
        var underlineStart: Int? = nil;
        var quoteStart: Int? = nil;
        var quoteLevel = 0;
        var idx = 0;
        
        var canStart = true;
        
        var wordIdx: Int? = showEmoticons ? 0 : nil;
        
        msg.removeAttribute(.underlineStyle, range: NSRange(location: 0, length: msg.length));
        msg.removeAttribute(.paragraphStyle, range: NSRange(location: 0, length: msg.length));
        msg.addAttribute(.font, value: font(withTextStyle: defTextStyle, andTraits: []), range: NSRange(location: 0, length: msg.length));
                
        while idx < message.length {
            let c = message.character(at: idx);
            switch c {
            case GT_SIGN:
                if quoteStart == nil && (idx == 0 || message.character(at: idx-1) == NEW_LINE) {
                    let start = idx;
                    while idx < message.length, message.character(at: idx) == GT_SIGN {
                        idx = idx + 1;
                    }
                    if idx < message.length && message.character(at: idx) == SPACE {
                        quoteStart = start;
                        quoteLevel = idx - start;
                        msg.addAttribute(.foregroundColor, value: stylingColor, range: NSRange(location: start, length: idx - start));
                    } else {
                        idx = idx - 1;
                    }
                }
            case ASTERISK:
                let nidx = idx + 1;
                if nidx < message.length, message.character(at: nidx) == ASTERISK {
                    if boldStart == nil {
                        if canStart {
                            boldStart = idx;
                        }
                    } else {
                        msg.addAttribute(.foregroundColor, value: stylingColor, range: NSRange(location: boldStart!, length: (nidx+1) - idx));
                        msg.addAttribute(.foregroundColor, value: stylingColor, range: NSRange(location: idx, length: (nidx+1) - idx));
                        
                        
                        msg.enumerateAttribute(.font, in: NSRange(location: boldStart!, length: (nidx+1) - boldStart!), options: .init()) { (attr, range: NSRange, stop) -> Void in
                            let boldFont = Markdown.font(withTextStyle: defTextStyle, andTraits: .traitBold);
                            msg.addAttribute(.font, value: boldFont, range: range);
                        }
                        
                        boldStart = nil;
                    }
                    canStart = true;
                    idx = nidx;
                } else {
                    if italicStart == nil {
                        if canStart {
                            italicStart = idx;
                        }
                    } else {
                        msg.addAttribute(.foregroundColor, value: stylingColor, range: NSRange(location: italicStart!, length: 1));
                        msg.addAttribute(.foregroundColor, value: stylingColor, range: NSRange(location: idx, length: 1));
                        
                        msg.enumerateAttribute(.font, in: NSRange(location: italicStart!, length: (idx+1) - italicStart!), options: .init()) { (attr, range: NSRange, stop) -> Void in
                            let italicFont = Markdown.font(withTextStyle: defTextStyle, andTraits: .traitItalic)
                            msg.addAttribute(.font, value: italicFont, range: range);
                        }
                        
                        italicStart = nil;
                    }
                    canStart = true;
                }
            case UNDERSCORE:
                if underlineStart == nil {
                    if canStart {
                        underlineStart = idx;
                    }
                } else {
                    msg.addAttribute(.foregroundColor, value: stylingColor, range: NSRange(location: underlineStart!, length: 1));
                    msg.addAttribute(.foregroundColor, value: stylingColor, range: NSRange(location: idx, length: 1));
                    
                    msg.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: underlineStart!, length: idx - underlineStart!));
                    underlineStart = nil;
                }
                canStart = true;
            case GRAVE_ACCENT:
//                if codeStart == nil {
                    if canStart {
                        let codeStart = idx;
                        let isBlock = 0 == idx || (message.character(at: idx-1) == NEW_LINE) || (idx > 3 && message.length > (idx + 1) && message.character(at: idx + 1) == SPACE && message.character(at: idx-2) == GT_SIGN && (0 == idx - 3 || message.character(at: idx - 3) == NEW_LINE));
                        wordIdx = nil;
                        while idx < message.length, message.character(at: idx) == "`" {
                            idx = idx + 1;
                        }
                        let codeCount = idx - codeStart;
                        
                        var count = 0;
                        while idx < message.length {
                            if message.character(at: idx) == GRAVE_ACCENT {
                                count = count + 1;
                                if count == codeCount {
                                    let tmp = idx + 1;
                                    if tmp == message.length || [" ", "\n"].contains(message.character(at: tmp)) {
                                        break;
                                    }
                                }
                            } else {
                                count = 0;
                            }
                            idx = idx + 1;
                        }
                        if codeCount != count {
                            idx = codeStart + codeCount;
                        } else {
                            msg.addAttribute(.foregroundColor, value: stylingColor, range: NSRange(location: codeStart, length: codeCount));
                            msg.addAttribute(.foregroundColor, value: stylingColor, range: NSRange(location: (idx+1)-codeCount, length: codeCount));

                            let codeFont = Markdown.code(withTextStyle: defTextStyle);
                            msg.addAttribute(.font, value: codeFont, range: NSRange(location: codeStart, length: idx - codeStart));

                            if isBlock {
                                msg.addAttribute(.paragraphStyle, value: codeParagraphStyle, range: NSRange(location: codeStart, length: idx - codeStart));
                            }
                                                                                    
                            if idx - codeStart > 1 {
                                let clearRange = NSRange(location: codeStart + codeCount, length: idx - (codeStart + (2*codeCount)));
                                //msg.removeAttribute(.foregroundColor, range: clearRange);
                                msg.removeAttribute(.underlineStyle, range: clearRange);
                                //msg.addAttribute(.foregroundColor, value: textColor ?? NSColor.textColor, range: clearRange);
                            }
                            
                            if idx == message.length {
                                wordIdx = message.length;
                            } else {
                                wordIdx = idx + 1;
                            }
                        }
                    }
//                } else {
//                }
                canStart = true;
            case CR_SIGN, NEW_LINE, SPACE:
                if showEmoticons {
                    if wordIdx != nil && wordIdx! != idx {
                        // something is wrong, it looks like IDX points to replaced value!
                        let range = NSRange(location: wordIdx!, length: idx - wordIdx!);
                        if let emoji = String.emojis[message.substring(with: range)] {
                            let len = message.length;
                            logger.debug("replacing: \(range), for: \(emoji), in: \(msg), range: \(NSRange(location: 0, length: msg.length))");
                            msg.replaceCharacters(in: range, with: emoji);
                            message = msg.string as NSString;
                            let diff = message.length - len;
                            idx = idx + diff;
                        }
                    }
                    if idx < message.length {
                        wordIdx = idx + 1;
                    } else {
                        wordIdx = message.length;
                    }
                }
                if NEW_LINE == c {
                    boldStart = nil;
                    underlineStart = nil;
                    italicStart = nil
                    if (quoteStart != nil) {
                        logger.debug("quote level: \(quoteLevel)");
                        if idx < message.length {
                            let range = NSRange(location: quoteStart!, length: idx - quoteStart!);
                            logger.debug("message possibly causing a crash: \(message), range: \(range), length: \(message.length)");
                            msg.addAttribute(.paragraphStyle, value: Markdown.quoteParagraphStyle, range: range);
                        }
                        quoteStart = nil;
                    }
                }
                canStart = true;
            default:
                canStart = false;
                break;
            }
            if idx < message.length {
                idx = idx + 1;
            }
        }

        if (quoteStart != nil) {
            msg.addAttribute(.paragraphStyle, value: Markdown.quoteParagraphStyle, range: NSRange(location: quoteStart!, length: idx - quoteStart!));
            quoteStart = nil;
        }

        if showEmoticons && wordIdx != nil && wordIdx! != idx {
            let range = NSRange(location: wordIdx!, length: idx - wordIdx!);
            if let emoji = String.emojis[message.substring(with: range)] {
                msg.replaceCharacters(in: range, with: emoji);
                message = msg.string as NSString;
            }
        }
        
        msg.fixAttributes(in: NSRange(location: 0, length: msg.length));
    }
    
}

extension String {
    
    static let emojisList = [
        "😳": ["O.o"],
        "☺️": [":-$", ":$"],
        "😄": [":-D", ":D", ":-d", ":d", ":->", ":>"],
        "😉": [";-)", ";)"],
        "😊": [":-)", ":)"],
        "😡": [":-@", ":@"],
        "😕": [":-S", ":S", ":-s", ":s", ":-/", ":/"],
        "😭": [";-(", ";("],
        "😮": [":-O", ":O", ":-o", ":o"],
        "😎": ["B-)", "B)"],
        "😐": [":-|", ":|"],
        "😛": [":-P", ":P", ":-p", ":p"],
        "😟": [":-(", ":("]
    ];
    
    static var emojis: [String:String] = Dictionary(uniqueKeysWithValues: String.emojisList.flatMap({ (arg0) -> [(String,String)] in
        let (k, list) = arg0
        return list.map { v in return (v, k)};
    }));
    
    func emojify() -> String {
        var result = self;
        let words = components(separatedBy: " ").filter({ s in !s.isEmpty});
        for word in words {
            if let emoji = String.emojis[word] {
                result = result.replacingOccurrences(of: word, with: emoji);
            }
        }
        return result;
    }
}
