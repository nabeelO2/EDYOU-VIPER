//
// StepperTableViewCell.swift
//
// EdYou
// Copyright (C) 2017 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Combine

class StepperTableViewCell: UITableViewCell {
    
    @IBOutlet var labelView: UILabel!
    @IBOutlet var stepperView: UIStepper!
    
    var valueChangedListener: ((UIStepper) -> Void)?;
    var updateLabel: ((Double)->String?)?;
    
    private var cancellables: Set<AnyCancellable> = [];
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func valueChanged(_ sender: UIStepper) {
        valueChangedListener?(sender);
        setValue(stepperView.value);
    }
    
    func setValue(_ value: Double) {
        stepperView.value = value;
        if updateLabel != nil {
            labelView.text = updateLabel!(value);
        }
    }

    func reset() {
        cancellables.removeAll();
    }
    
    func assign(from publisher: AnyPublisher<Double,Never>, labelGenerator: ((Double)->String)? = nil) {
        publisher.removeDuplicates().assign(to: \.value, on: stepperView).store(in: &cancellables);
        if labelGenerator != nil {
            publisher.map(labelGenerator!).assign(to: \.text, on: labelView).store(in: &cancellables);
        }
    }

    func assign(from publisher: AnyPublisher<Int,Never>, labelGenerator: ((Int)->String)? = nil) {
        publisher.map({ Double($0) }).removeDuplicates().assign(to: \.value, on: stepperView).store(in: &cancellables);
        if labelGenerator != nil {
            publisher.map(labelGenerator!).assign(to: \.text, on: labelView).store(in: &cancellables);
        }
    }

    func sink<Root>(to keyPath: ReferenceWritableKeyPath<Root, Double>, on object: Root) {
        stepperView.publisher(for: \.value).removeDuplicates().assign(to: keyPath, on: object).store(in: &cancellables);
    }

    func sink<Root>(to keyPath: ReferenceWritableKeyPath<Root, Int>, on object: Root) {
        stepperView.publisher(for: \.value).map({ Int($0) }).removeDuplicates().assign(to: keyPath, on: object).store(in: &cancellables);
    }
    
    func bind(_ fn: (StepperTableViewCell)->Void) {
        reset();
        fn(self);
    }

}
