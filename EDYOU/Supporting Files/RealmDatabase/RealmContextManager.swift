//
//  DBManager.swift
//  Muslim360
//
//  Created by Masroor Elahi on 2/7/19.
//  Copyright © 2019 TEO International. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class RealmContextManager {
    
    static let shared = RealmContextManager()
    
    var _realmQueue : DispatchQueue!
    
    class func RealmQueue() -> DispatchQueue {
        return RealmContextManager.shared._realmQueue
    }
    
    /// Clear all data from realm
    func clearRealmDB() {
        _realmQueue.async {
            let realm = try? Realm()
            realm?.beginWrite()
            realm?.deleteAll()
            try? realm?.commitWrite()
        }
    }
    /// Prepare realm with configurations and migration block
    func prepareDefaultRealm() {
        _realmQueue.async {
            let config = Realm.Configuration(
                schemaVersion: 1,
                migrationBlock: { _, oldSchemaVersion in
                    if oldSchemaVersion < 1 {
                    }
                })
            Realm.Configuration.defaultConfiguration = config
            self.tryRealmObject()
        }
    }
    /// Fallback for realm - Incase realm fails to initialize due to any reason. Remove realm file and start again
    func tryRealmObject() {
        
        _realmQueue.async {
            do {
                _ = try Realm()
            } catch let error {
                print(error.localizedDescription)
                if let realmFile = Realm.Configuration.defaultConfiguration.fileURL {
                    try? FileManager.default.removeItem(at: realmFile)
                }
            }
        }
    }
    var realm: Realm?
    /// Initialize Realm
    /// - Parameter realm: Realm Object
    init() {
        _realmQueue = DispatchQueue(label: Constants.realmThread)
        _realmQueue.async {
            self.realm = try? Realm()
        }
    }
   
    func update(object: Storable) throws {
        guard let realm = try? Realm() else {
            throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel
        }
        guard let object = object as? Object else {
            return
        }
        do {
            try realm.safeWrite {
                realm.add(object, update: .modified)
       
            }
        } catch let excep {
            throw RealmError.realmException(excep.localizedDescription)
        }
#if DEBUG
        print(realm.configuration.fileURL ?? "")
#endif
    }

  
    func save(object: Storable) throws {
        guard let realm = try? Realm() else {
            throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel
        }
        guard let object = object as? Object else {
            return
        }
        do {
            try realm.safeWrite {
                realm.add(object, update: .modified)
            }
        } catch let excep {
            throw RealmError.realmException(excep.localizedDescription)
        }
#if DEBUG
        print(realm.configuration.fileURL ?? "")
#endif
    }
    
    func update(block: @escaping () -> Void ) throws {
        guard let realm = try? Realm() else {
            throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel
        }
#if DEBUG
        print(realm.configuration.fileURL ?? "")
#endif
        do {
            try realm.safeWrite {
                block()
            }
        } catch let excep {
            throw RealmError.realmException(excep.localizedDescription)
        }
    }
    
    func delete(object: Storable) throws {
        guard let realm = try? Realm() else {
            throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel
        }
        guard let object = object as? Object else {
            return
        }
        do {
            try realm.safeWrite {
                realm.delete(object)
            }
        } catch let excep {
            throw RealmError.realmException(excep.localizedDescription)
        }
    }
    
    func truncate<T>(_ model: T.Type) throws where T: Storable {
        guard let realm = try? Realm() else {
            throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel
        }
        do {
            try realm.safeWrite {
                guard let castType = model as? Object.Type else {
                    return
                }
                
                let allNotifications = realm.objects(castType)
                realm.delete(allNotifications)
            }
        } catch let excep {
            throw RealmError.realmException(excep.localizedDescription)
        }
    }
    
    func fetch<T>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted? = nil , completion: (([T]) -> Void)) where T: Storable {
            do {
                guard let realm = try? Realm() else {
                    throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel
                }
                guard let castType = model as? Object.Type else {
                    return
                }
                var result: Results<Object>
                if let sorted = sorted , let predicate = predicate {
                    result = realm.objects(castType).filter(predicate).sorted(byKeyPath: sorted.key, ascending: sorted.ascending).freeze()
                }
                if let sorted = sorted {
                    result = realm.objects(castType).sorted(byKeyPath: sorted.key, ascending: sorted.ascending).freeze()
                }
                if let predicate = predicate {
                    result = realm.objects(castType).filter(predicate).freeze()
                } else {
                    result = realm.objects(castType).freeze()
                }
                let typeArray: [T] = result.toArray(type: model)

                completion(typeArray)
                
            } catch let excep {
                print(excep.localizedDescription)
            }
        }
  
    func DetachedCopy<T:Codable>(of object:T, completion: @escaping (_ T : T? , _ success: Bool) -> Void){
        _realmQueue.async {
            do{
                let json = try JSONEncoder().encode(object)
                completion(try JSONDecoder().decode(T.self, from: json), true)
            }
            catch let error{
                completion(object, false)
                print(error)
            }
        }
        
    }
    
    func save(list: [Object]) throws {
        guard let realm = try? Realm() else {
                    throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel
        }
        let mappedList = list.compactMap({$0 as? Object})
                
                
            do {
                try realm.safeWrite {
                realm.add(mappedList,update: .all)
            }
        } catch let excep {
                throw RealmError.realmException(excep.localizedDescription)
        }
        #if DEBUG
                print("RealmFileURL:" + (realm.configuration.fileURL?.absoluteString ?? ""))
        #endif
    }
    
  
    func delete<T>(_ model: T.Type, predicate: NSPredicate?, completion: ((Bool) -> Void))
    {
            do {
                guard let realm = try? Realm() else {
                    throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel
                }
                guard let castType = model as? Object.Type else {
                return
            }
            guard let realm = try? Realm() else {
                throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel
            }
            var result: Results<Object>
            if let predicate = predicate {
                result = realm.objects(castType).filter(predicate)
            } else {
                result = realm.objects(castType)
            }
            let mappedList = result.compactMap({$0 as? Object})
            do {
                try realm.safeWrite {
                    realm.delete(mappedList)
                    completion(true)
                }
            } catch let excep {
                throw RealmError.realmException(excep.localizedDescription)
                
            }
            #if DEBUG
                print(realm.configuration.fileURL ?? "")
            #endif
            }
            catch let excep {
                print(excep.localizedDescription)
            }
    }
    
    func delete(list: [Storable]) throws {
        guard let realm = try? Realm() else {
            throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel
        }
        let mappedList = list.compactMap({$0 as? Object})
        do {
            try realm.safeWrite {
                realm.delete(mappedList)
            }
        } catch let excep {
            throw RealmError.realmException(excep.localizedDescription)
        }
#if DEBUG
        print(realm.configuration.fileURL ?? "")
#endif
    }
    
    func create<T>(_ model: T.Type, updates: Any?, completion: @escaping ((T) -> Void)) throws where T: Storable {
    }
    
}

extension Results {
    /// Convert Realm Arrat To Swift Array
    /// - Parameter type: Realm Array
    /// - Returns: Swift Array
    ///
    ///
  
   

    
    func totheArray() -> [Results.Iterator.Element] {
            return map { $0 }
        }
    func toArray<T>(type: T.Type) -> [T] {
           return compactMap { $0 as? T }
       }
    
   
    func toObjectArray () -> [Object] {
        var array = [Object]()
        for result in self {
            array.append((result as? Object)!)
        }
        return array
      }
    func toArray<T>(ofType: T.Type) -> [T] {
          var array = [T]()
          for i in 0 ..< count {
              if let result = self[i] as? T {
                  array.append(result )
              }
          }

          return array
      }
    func toArray() -> [Element] {
         return compactMap {
           $0
         }
       }
}

extension List {
    /// Convert Realm List to Swift Array
    /// - Parameter type: Realm List Type
    /// - Returns: Swift Array with mentioned type
    func toArray<T>(type: T.Type) -> [T] {
        return compactMap { $0 as? T }
    }
}

extension Array {
    /// Convert Swift Array to Realm List
    /// - Parameter type: Swift List Type
    /// - Returns: Realm List with type
    func toRealmList<T: Object>(type: T.Type) -> List<T> {
        let list = List<T>()
        let value = compactMap({$0 as? T})
        list.append(objectsIn: value)
        return list
    }
}

// Uncomment this for clone
protocol DetachableObject: AnyObject {
    /// Clone of Realm Object
    func detached() -> Self
}

extension Object: DetachableObject {
    func detached() -> Self {
        let detached = type(of: self).init()
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else {
                continue
            }
            if let detachable = value as? DetachableObject {
                detached.setValue(detachable.detached(), forKey: property.name)
            } else { // Then it is a primitive
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
}

extension List: DetachableObject {
    func detached() -> List<Element> {
        let result = List<Element>()
        forEach {
            if let detachableObject = $0 as? DetachableObject,
               let element = detachableObject.detached() as? Element {
                result.append(element)
            } else { // Then it is a primitive
                result.append($0)
            }
        }
        return result
    }
}

extension Array where Element: DetachableObject {
    func detached() -> [Element] {
        var result = [Element]()
        forEach {
            result.append($0.detached())
        }
        return result
    }
}
extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}
