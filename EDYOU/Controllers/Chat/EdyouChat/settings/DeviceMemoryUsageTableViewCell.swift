//
// DeviceMemoryUsageTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit

class DeviceMemoryUsageTableViewCell: UITableViewCell {
    
    let chartView = UsageChartView();
    
    var diskSpace = DiskSpace.current();
        
    override func awakeFromNib() {
        super.awakeFromNib();
        chartView.translatesAutoresizingMaskIntoConstraints = false;
        contentView.addSubview(chartView);
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: chartView.topAnchor, constant: -20),
            contentView.leadingAnchor.constraint(equalTo: chartView.leadingAnchor, constant: -20),
            contentView.trailingAnchor.constraint(equalTo: chartView.trailingAnchor, constant: 20),
            contentView.bottomAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 20)
        ]);
        
        chartView.maximumValue = Double(diskSpace.total);
        
        let downloadsSize = DownloadStore.instance.size;
        let metadataSize = MetadataCache.instance.size;
        
        let usedByUs = downloadsSize + metadataSize;
        
        chartView.items = [
            .init(color: .systemYellow, value: Double(downloadsSize), name: NSLocalizedString("Downloads", comment: "memory usage label")),
            .init(color: .systemGreen, value: Double(metadataSize), name: NSLocalizedString("Link previews", comment: "memory usage label")),
            .init(color: .lightGray, value: Double(diskSpace.used - usedByUs), name: NSLocalizedString("Other apps", comment: "memory usage label")),
            .init(color: .systemGray, value: Double(diskSpace.free), name: NSLocalizedString("Free", comment: "memory usage label"))
        ]
    }
    
    struct DiskSpace {
        let total: Int;
        let free: Int;
        var used: Int {
            return total - free;
        }
        
        static func current() -> DiskSpace {
            do {
                let attrs = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory());
                let total = (attrs[.systemSize] as? NSNumber)?.intValue ?? 0;
                let free = (attrs[.systemFreeSize] as? NSNumber)?.intValue ?? 0;
                return .init(total: total, free: free);
            } catch {
                return DiskSpace(total: 0, free: 0);
            }
        }
    }
    
}

