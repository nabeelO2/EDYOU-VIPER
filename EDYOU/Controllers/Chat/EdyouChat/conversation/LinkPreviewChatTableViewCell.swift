//
// LinkPreviewChatTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit
import LinkPresentation

class LinkPreviewChatTableViewCell: BaseChatTableViewCell {
    
    private var url: URL?;
    
    var linkView: LPLinkView? {
        didSet {
            if let value = oldValue {
                value.metadata = LPLinkMetadata();
                value.removeFromSuperview();
            }
            if let value = linkView {
                self.contentView.addSubview(value);
                NSLayoutConstraint.activate([
                    value.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 2),
                    value.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4),
                    value.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 44),
                    value.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -22)
                ]);
            }
        }
    }
    
    override func prepareForReuse() {
        self.url = nil;
        self.linkView?.metadata = LPLinkMetadata();
        super.prepareForReuse();
    }
        
    func set(item: ConversationEntry, url inUrl: String) {
        super.set(item: item);

        self.contentView.setContentCompressionResistancePriority(.required, for: .vertical);
        self.contentView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal);
        
        let url = URL(string: inUrl)!;
        self.url = url;
        
        guard let metadata = MetadataCache.instance.metadata(for: "\(item.id)") else {
            setup(linkView: LPLinkView(metadata: createMetadata(url: url)));
            
            MetadataCache.instance.generateMetadata(for: url, withId: "\(item.id)", completionHandler: { [weak self] meta in
                guard meta != nil else {
                    return;
                }
                DispatchQueue.main.async {
                    guard let that = self, that.url == url else {
                        return;
                    }

                    NotificationCenter.default.post(name: ConversationLogController.REFRESH_CELL, object: that);
                }
            })
            
            return;
        }
        
        setup(linkView: LPLinkView(metadata: metadata));
    }
    
    private func createMetadata(url: URL) -> LPLinkMetadata {
        let metadata = LPLinkMetadata();
        metadata.originalURL = url;
        return metadata;
    }
    
    private func setup(linkView: LPLinkView) {
        linkView.setContentCompressionResistancePriority(.required, for: .vertical);
        linkView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal);
        linkView.translatesAutoresizingMaskIntoConstraints = false;
        self.linkView = linkView;
    }
}
