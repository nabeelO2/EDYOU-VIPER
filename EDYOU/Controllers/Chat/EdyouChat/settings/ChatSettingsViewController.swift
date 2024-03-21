//
// ChatSettingsViewController.swift
//
// EdYou
// Copyright (C) 2017 "O2Geeks." <admin@o2geeks.com>
//
 
//

import UIKit

class ChatSettingsViewController: UITableViewController {

    let tree: [[SettingsEnum]] = {
            return [
            [SettingsEnum.recentsMessageLinesNo],
            [SettingsEnum.sendMessageOnReturn, SettingsEnum.messageDeliveryReceipts, SettingsEnum.messageEncryption, SettingsEnum.linkPreviews],
                [SettingsEnum.media]
                ];
        }();
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tree.count;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tree[section].count;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("List of messages", comment: "section label")
        case 1:
            return NSLocalizedString("Messages", comment: "section label")
        case 2:
            return NSLocalizedString("Attachments", comment: "section label")
        default:
            return nil;
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = tree[indexPath.section][indexPath.row];
        switch setting {
        case .recentsMessageLinesNo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentsMessageLinesNoTableViewCell", for: indexPath ) as! StepperTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$recentsMessageLinesNo, labelGenerator: { val in
                    return val == 1 ? NSLocalizedString("1 line of preview", comment: "no. of lines of messages preview label") : String.localizedStringWithFormat(NSLocalizedString("%d lines of preview", comment: "no. of lines of messages preview label"), val);
                });
                cell.sink(to: \.recentsMessageLinesNo, on: Settings);
            })
            return cell;
        case .messageDeliveryReceipts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageDeliveryReceiptsTableViewCell", for: indexPath) as! SwitchTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$confirmMessages);
                cell.sink(to: \.confirmMessages, on: Settings);
            })
            return cell;
        case .linkPreviews:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LinkPreviewsTableViewCell", for: indexPath) as! SwitchTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$linkPreviews);
                cell.sink(to: \.linkPreviews, on: Settings);
            })
            return cell;
        case .sendMessageOnReturn:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendMessageOnReturnTableViewCell", for: indexPath) as! SwitchTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$sendMessageOnReturn);
                cell.sink(to: \.sendMessageOnReturn, on: Settings);
            })
            return cell;
        case .messageEncryption:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageEncryptionTableViewCell", for: indexPath) as! EnumTableViewCell;
            cell.bind({ cell in
                cell.assign(from: Settings.$messageEncryption);
            })
            cell.accessoryType = .disclosureIndicator;
            return cell;
        case .media:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MediaSettingsViewCell", for: indexPath);
            return cell;
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        let setting = tree[indexPath.section][indexPath.row];
        switch setting {
        case .messageEncryption:
            let controller = TablePickerViewController<ChatEncryption>(style: .grouped, message: NSLocalizedString("Select default conversation encryption", comment: "selection information"), options: [.omemo], value: Settings.messageEncryption);
            controller.sink(to: \.messageEncryption, on: Settings)
            self.navigationController?.pushViewController(controller, animated: true);

        default:
            break;
        }
    }
    
    internal enum SettingsEnum {
        case recentsMessageLinesNo
        case messageDeliveryReceipts
        case linkPreviews
        case sendMessageOnReturn
        case messageEncryption
        case media
    }
    
}
