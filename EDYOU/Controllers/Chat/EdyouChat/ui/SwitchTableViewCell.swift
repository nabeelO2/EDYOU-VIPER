//
// SwitchTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Combine

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet var switchView: UISwitch!
    
    var valueChangedListener: ((UISwitch) -> Void)?;
    
    private var cancellables: Set<AnyCancellable> = [];
    private let subject = PassthroughSubject<Bool, Never>();
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func valueChanged(_ sender: UISwitch) {
        valueChangedListener?(sender);
        subject.send(sender.isOn);
    }
    
    func reset() {
        cancellables.removeAll();
    }
    
    func assign(from publisher: AnyPublisher<Bool,Never>) {
        publisher.removeDuplicates().assign(to: \.isOn, on: switchView).store(in: &cancellables);
    }

    func sink<Root>(to keyPath: ReferenceWritableKeyPath<Root, Bool>, on object: Root) {
        subject.removeDuplicates().assign(to: keyPath, on: object).store(in: &cancellables);
    }

    func sink<Root,T>(map: @escaping (Bool)->T, to keyPath: ReferenceWritableKeyPath<Root, T>, on object: Root) {
        subject.removeDuplicates().map(map).assign(to: keyPath, on: object).store(in: &cancellables);
    }
    
    func bind(_ fn: (SwitchTableViewCell)->Void) {
        reset();
        fn(self);
    }
}
