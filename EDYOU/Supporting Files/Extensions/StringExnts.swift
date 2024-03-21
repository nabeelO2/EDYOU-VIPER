//
//  StringExnts.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import Foundation
import Photos
import UIKit
import CommonCrypto

extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var toDate: Date? {
        var date: Date? = nil
        var dateString = self
    
        if dateString.contains("0000-01-01T") {
            dateString = dateString.replacingOccurrences(of: "0000-01-01T", with: Date().stringValue(format: "yyyy-MM-dd", timeZone: .current) + "T")
        }
        
        let formates = ["yyyy-MM-dd'T'HH:mm:ss.SSSXXX", "yyyy-MM-dd'T'HH:mm:ss.SSSS", "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd'T'HH:mm:ss", "dd MMM yyyy", "dd-MM-yyyy", "MM-dd-yyyy", "MM-yyyy-dd", "yyyy-MM-dd"]
        for f in formates {
            if let d = dateString.dateValue(format: f) {
                date = d
                break
            }
        }
        
        return date
    }
    
    func dateValue(format: String, timeZone: TimeZone? = TimeZone(abbreviation: "UTC")) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: self)
        
    }
    func height(withWidth width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [.font : font], context: nil)
        return actualSize.height
    }
    
    func width(withHeight height: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [.font : font], context: nil)
        return actualSize.width
    }
    
    func trunc(length: Int, trailing: String = "…") -> String {
        if (self.count <= length) {
          return self
        }
        let truncated = self.prefix(length)
//        while truncated.last != " " {
//          truncated = truncated.dropLast()
//        }
        return truncated + trailing
      }
    
    static func createUniqueFileName(length: Int = 20) -> String {

        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
       }
    // MARK: - Captilization
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    var containsDigits : Bool {
           return(self.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil)
       }
    var containsWhitespace : Bool {
          return(self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
      }
}


extension String {
    
    func decodeEmoji() -> String {
        guard let data = self.data(using: .utf8) else { return "" }
        return String(data: data, encoding: .nonLossyASCII) ?? self
    }
    
    func encodeEmoji() -> String {
        guard let data = self.data(using: .nonLossyASCII, allowLossyConversion: true) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    var intials:String {
        return String(self.split(separator: " ").map{String(String($0).first ?? Character(""))}.filter{!$0.isEmpty}.joined(separator: " ").prefix(3))
    }
}


extension Date {
    func stringValue(format: String, timeZone: TimeZone? = TimeZone(abbreviation: "GMT")) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        // No need to hardCode the zone either get it from device or use default value.
//        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: self)
    }
    
    
    func dateByAdding(hours: Int) -> Date? {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self)
    }
    func dateByAdding(days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: self)
    }
    func dateByAdding(months: Int) -> Date? {
        return Calendar.current.date(byAdding: .month, value: months, to: self)
    }
    func dateByAdding(years: Int) -> Date? {
        return Calendar.current.date(byAdding: .year, value: years, to: self)
    }
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    var startOfMonth: Date {

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)

        return  calendar.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    var timeText: String {
        if self.stringValue(format: "yyyy-MM-dd", timeZone: .current) == Date().stringValue(format: "yyyy-MM-dd", timeZone: .current) {
            return self.stringValue(format: "hh:mm a", timeZone: .current)
        } else if self.stringValue(format: "yyyy", timeZone: .current) == Date().stringValue(format: "yyyy", timeZone: .current) {
            return self.stringValue(format: "MMM dd, hh:mm a", timeZone: .current)
        }
        return self.stringValue(format: "MMM dd yyyy, hh:mm a", timeZone: .current)
    }
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    func toUTC(format: String = "yyyy-MM-dd'T'HH:mm:ss") -> String {
        return self.stringValue(format: format)
    }
    func toYYYYMMDD() -> String {
        return self.stringValue(format: "yyyy-MM-dd", timeZone: .current)
    }
    func toddMMMyyyy() -> String {
        return self.stringValue(format: "dd MMM yyyy", timeZone: .current)
    }
    func ddMMyyyyhhmma() -> String {
        return self.stringValue(format: "dd-MM-yyyy hh:mm a", timeZone: .current)
    }
    
    func isGreaterThan(_ date: Date) -> Bool {
         return self > date
      }
    
    func isEqualTo(_ date: Date) -> Bool {
        return self == date
      }
    
    func isSmallerThan(_ date: Date) -> Bool {
         return self < date
      }
}

extension NSObject {
    static var name: String {
        return String(describing: self)
    }
}

extension Array {
    func object(at index: Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        }
        return nil
    }
}

extension PHAsset {
    func getThumbnail(completion: @escaping (_ image: UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        manager.requestImage(for: self, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: option) { result, info in
            completion(result)
        }
    }
}

extension Int {
    mutating func increment(by: Int = 1) {
        self += 1
    }
    mutating func decrement(by: Int = 1) {
        self -= 1
    }
    var toMinutesSeconds: String {
        let minutes = Double(self) / 60
        let seconds = self % 60
        return String(format:"%02d:%02d", minutes, seconds);
    }
}

extension Optional {
    func asStringOrEmpty() -> String {
        switch self {
            case .some(let value):
                return String(describing: value)
            case _:
                return ""
        }
    }
    
    func asBoolOrFalse() -> Bool {
        switch self {
            case .some(let value):
                return value as? Bool ?? false
            case _:
                return false
        }
    }
}

extension Optional {
    func isStringEmpty() -> Bool {
        switch self {
            case .some(let value):
            return String(describing: value).isEmpty
            case _:
                return true
        }
    }
    func isTrimmedEmpty() -> Bool {
        switch self {
            case .some(let value):
            return String(describing: value).trimmed.isEmpty
            case _:
                return true
        }
    }
}

extension Calendar {
    /*
    Week boundary is considered the start of
    the first day of the week and the end of
    the last day of the week
    */
    typealias WeekBoundary = (startOfWeek: Date?, endOfWeek: Date?)
    
    func currentWeekBoundary() -> WeekBoundary? {
        return weekBoundary(for: Date())
    }
    
    func weekBoundary(for date: Date) -> WeekBoundary? {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        
        guard let startOfWeek = self.date(from: components) else {
            return nil
        }
        
        let endOfWeekOffset = weekdaySymbols.count - 1
        let endOfWeekComponents = DateComponents(day: endOfWeekOffset, hour: 23, minute: 59, second: 59)
        guard let endOfWeek = self.date(byAdding: endOfWeekComponents, to: startOfWeek) else {
            return nil
        }
        
        return (startOfWeek, endOfWeek)
    }
}

extension UITextField {
    func datePicker<T>(target: T,
                       doneAction: Selector,
                       cancelAction: Selector,
                       datePickerMode: UIDatePicker.Mode = .date) {
        let screenWidth = UIScreen.main.bounds.width
        
        func buttonItem(withSystemItemStyle style: UIBarButtonItem.SystemItem) -> UIBarButtonItem {
            let buttonTarget = style == .flexibleSpace ? nil : target
            let action: Selector? = {
                switch style {
                case .cancel:
                    return cancelAction
                case .done:
                    return doneAction
                default:
                    return nil
                }
            }()
            
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: style,
                                                target: buttonTarget,
                                                action: action)
            
            return barButtonItem
        }
        
        let datePicker = UIDatePicker(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: screenWidth,
                                                    height: 216))
        datePicker.datePickerMode = datePickerMode
        datePicker.preferredDatePickerStyle = .wheels
        self.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0,
                                              y: 0,
                                              width: screenWidth,
                                              height: 44))
        toolBar.setItems([buttonItem(withSystemItemStyle: .cancel),
                          buttonItem(withSystemItemStyle: .flexibleSpace),
                          buttonItem(withSystemItemStyle: .done)],
                         animated: true)
        self.inputAccessoryView = toolBar
    }
}
