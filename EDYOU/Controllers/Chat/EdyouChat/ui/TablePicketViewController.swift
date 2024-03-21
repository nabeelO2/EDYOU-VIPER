//
// TablePicketView.swift
//
// EdYou
// Copyright (C) 2017 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import Combine

class TablePickerViewController<Value>: UITableViewController where Value: Equatable {

    @Published
    private var selected: Int = 0;
    private let options: [Value];
    private let optionLabels: [String];
    
    private var message: String?;
    private var footer: String?;
    
    private var cancellables: Set<AnyCancellable> = [];
    
    init(style: UITableView.Style = .grouped, message: String? = nil, footer: String? = nil, options: [Value], value: Value, labelFn: (Value)->String) {
        self.message = message;
        self.footer = footer;
        self.options = options;
        self.optionLabels = options.map(labelFn);
        self.selected = options.firstIndex(where: { $0 == value }) ?? 0;
        super.init(style: style);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "item");
        tableView.dataSource = self;
        tableView.delegate = self;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return message;
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return footer;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath);
        cell.textLabel!.text = optionLabels[indexPath.row];
        cell.accessoryType = indexPath.row == selected ? .checkmark : .none;
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false);
        if selected != indexPath.row {
            selected = indexPath.row;
            tableView.reloadData();
        }
    }
    
    func sink<Root>(to keyPath: ReferenceWritableKeyPath<Root, Value>, on object: Root) {
        $selected.map({ self.options[$0] }).assign(to: keyPath, on: object).store(in: &cancellables);
    }
    
    func sink(receiveValue: @escaping (Value)->Void) {
        $selected.map({ self.options[$0] }).sink(receiveValue: receiveValue).store(in: &cancellables);
    }
}

extension TablePickerViewController where Value : CustomStringConvertible {
        
    convenience init(style: UITableView.Style = .grouped, message: String? = nil, footer: String? = nil, options: [Value], value: Value) {
        self.init(style: style, message: message, footer: footer, options: options, value: value, labelFn: { v in v.description });
    }
}
    
protocol TablePickerViewItemsProtocol {
    
    var description: String { get };
    
}
