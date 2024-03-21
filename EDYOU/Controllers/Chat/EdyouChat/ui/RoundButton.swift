//
// RoundButton.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit

class RoundButton: UIButton {
    
    override func draw(_ rect: CGRect) {
        let offset = max(rect.width, rect.height) / 2;
        let tmp = CGRect(x: offset, y: offset, width: rect.width - (2 * offset), height: rect.height - (2 * offset));
        super.draw(tmp);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        layer.masksToBounds = true;
        layer.cornerRadius = self.frame.height / 2;
    }
}

class RoundedButton: UIButton {
        
    override func draw(_ rect: CGRect) {
        let offset = rect.height / 2;
        let tmp = CGRect(x: offset, y: offset, width: rect.width - (2 * offset), height: rect.height - (2 * offset));
        super.draw(tmp);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        layer.masksToBounds = true;
        layer.cornerRadius = min(self.frame.height, self.frame.width) / 2;
    }
}

class BadgeButton: RoundedButton {
    
    var widthConstratint: NSLayoutConstraint?;
    
    var title: String? {
        didSet {
            self.setTitle(title, for: .normal);
            self.isHidden = title?.isEmpty ?? true;
            if (isHidden) {
                NSLayoutConstraint.activate([widthConstratint!])
            } else {
                NSLayoutConstraint.deactivate([widthConstratint!]);
            }
            self.layoutSubviews();
            self.setNeedsDisplay();
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        setup();
    }
    
    private func setup() {
        widthConstratint = self.widthAnchor.constraint(equalToConstant: 0);
        NSLayoutConstraint.activate([widthConstratint!]);
        isHidden = true;
    }
    
}
