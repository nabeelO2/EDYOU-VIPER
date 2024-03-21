//
// EnumTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Combine

class EnumTableViewCell: UITableViewCell {
    
    private var cancellables: Set<AnyCancellable> = [];
    
    func reset() {
        cancellables.removeAll();
    }

    func assign(from publisher: AnyPublisher<String?,Never>) {
        if let label = self.detailTextLabel {
            publisher.assign(to: \.text, on: label).store(in: &cancellables);
        }
    }
    
    func assign(from publisher: AnyPublisher<CustomStringConvertible,Never>) {
        if let label = self.detailTextLabel {
            publisher.map({ $0.description }).assign(to: \.text, on: label).store(in: &cancellables);
        }
    }

    func assign<T: CustomStringConvertible>(from publisher: AnyPublisher<T,Never>) {
        if let label = self.detailTextLabel {
            publisher.map({ $0.description }).assign(to: \.text, on: label).store(in: &cancellables);
        }
    }

    func assign(from publisher: AnyPublisher<CustomStringConvertible?,Never>) {
        if let label = self.detailTextLabel {
            publisher.map({ $0?.description }).assign(to: \.text, on: label).store(in: &cancellables);
        }
    }

    func bind(_ fn: (EnumTableViewCell)->Void) {
        reset();
        fn(self);
    }
    
}
