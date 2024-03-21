//
// Array+IndexChanges.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//
import Foundation

extension Array {

    public struct IndexSetChanges {
        let removed: IndexSet;
        let inserted: IndexSet;
    }

}

extension Array where Element: Hashable {
    
    func calculateChanges(from source: Array<Element>) -> IndexSetChanges {
            let diff = self.difference(from: source);
            
            let removed = diff.removals.map({ change -> Int in
                switch change {
                case .insert(let offset, _, _):
                    return offset;
                case .remove(let offset, _, _):
                    return offset;
                }
            })
            
            let inserted = diff.insertions.map({ change -> Int in
                switch change {
                case .insert(let offset, _, _):
                    return offset;
                case .remove(let offset, _, _):
                    return offset;
                }
            })
            
            return .init(removed: IndexSet(removed), inserted: IndexSet(inserted));
    }
    
}
