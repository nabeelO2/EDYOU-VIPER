//
//  NSDictionaryExt.swift
//  Carzly
//
//  Created by Zuhair Hussain on 11/06/2019.
//  Copyright © 2019 Zuhair Hussain. All rights reserved.
//

import Foundation

extension NSDictionary {
    func bool(for key: String) -> Bool {
        if let val = self[key] as? Bool {
            return val
        } else if let val = self[key] as? String {
            return val.lowercased() == "true" || val.intValue > 0
        } else if let val = self[key] as? Int {
            return val > 0
        } else if let val = self[key] as? Double {
            return val > 0
        }
        return false
    }
    
    func string(for key: String, defaultValue: String = "") -> String {
        if let val = self[key] as? String {
            return val
        } else if let val = self[key] as? Int {
            return String(val)
        } else if let val = self[key] as? Double {
            return String(val)
        } else if let val = self[key] as? Bool {
            return val == true ? "true" : "false"
        }
        return defaultValue
    }
    func double(for key: String) -> Double {
        if let val = self[key] as? Double {
            return val
        } else if let val = self[key] as? String {
            return Double(val) != nil ? Double(val)! : 0
        } else if let val = self[key] as? Int {
            return Double(val)
        } else if let val = self[key] as? Bool {
            return val == true ? 1 : 0
        }
        return 0
    }
    func int(for key: String) -> Int {
        if let val = self[key] as? Int {
            return val
        } else if let val = self[key] as? String {
            return Int(val) != nil ? Int(val)! : 0
        } else if let val = self[key] as? Double {
            return Int(val)
        } else if let val = self[key] as? Bool {
            return val == true ? 1 : 0
        }
        return 0
    }
    
    func dictionary(for key: String) -> NSDictionary {
        if let dict = self[key] as? NSDictionary {
            return dict
        }
        return NSDictionary()
    }
    
    func array(for key: String) -> NSArray {
        if let dict = self[key] as? NSArray {
            return dict
        }
        return NSArray()
    }
    
    func setDefaultFor(key: String, value: Any) {
        if (self.allKeys as? [String])?.contains(key) == true {
            if self[key] is NSNull {
                self.setValue(value, forKey: key)
            }
        } else {
            self.setValue(value, forKey: key)
        }
    }
    
    func makeInt(key: String) {
        if (self.allKeys as? [String])?.contains(key) == true {
            self.setValue(self.int(for: key), forKey: key)
        } else {
            self.setValue(0, forKey: key)
        }
    }
    func makeDouble(key: String) {
        if (self.allKeys as? [String])?.contains(key) == true {
            self.setValue(self.double(for: key), forKey: key)
        } else {
            self.setValue(0.0, forKey: key)
        }
    }
    func makeBool(key: String) {
        if (self.allKeys as? [String])?.contains(key) == true {
            self.setValue(self.bool(for: key), forKey: key)
        } else {
            self.setValue(false, forKey: key)
        }
    }
    
    func toJson() -> String {
        if let jsonData = try?  JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: String.Encoding.ascii) {
            return jsonString
        }
        return ""
    }
}

extension Sequence where Iterator.Element == Int {
    func joined(by separator: String) -> String {
        var str = ""
        for (index, value) in self.enumerated() {
            if index == 0 {
                str = "\(value)"
            } else {
                str += separator + "\(value)"
            }
        }
        return str
    }
    var stringValues: [String] {
        var strngs = [String]()
        for i in self {
            strngs.append("\(i)")
        }
        return strngs
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

extension Sequence where Iterator.Element == String {
    var intValues: [Int] {
        var ints = [Int]()
        for s in self {
            ints.append(s.intValue)
        }
        return ints
    }
    func filter(containing text: String) -> [String] {
        let t = text.lowercased()
        var strings = [String]()
        for s in self {
            if s.lowercased().contains(t) {
                strings.append(s)
            }
        }
        return strings
    }
}

extension String {
    var intValue: Int {
        if let i = Int(self) {
            return i
        }
        return 0
    }
    var doubleValue: Double {
        if let i = Double(self) {
            return i
        }
        return 0
    }
    var dictionary: [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
