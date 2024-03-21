//
//  DocumentsTableCell.swift
//  EDYOU
//
//  Created by Admin on 16/06/2022.
//

import UIKit

class DocumentsTableCell: AboutSectionParentCell {
    
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var lblDocumentName: UILabel!
    @IBOutlet weak var lblDocumnetDescription: UILabel!
    @IBOutlet weak var documentImg: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.btnEdit.removeTarget(nil, action: nil, for: .allEvents)
        self.btnDelete.removeTarget(nil, action: nil, for: .allEvents)
//        self.btnEdit.addTarget(self, action: #selector(editButtonTapped(sender:)), for: .touchUpInside)
        self.btnDelete.addTarget(self, action: #selector(deleteButtonTapped(sender:)), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func setData(doc: UserDocument, delegate : AboutSectionCellDelegate?){
        lblDocumentName.text = doc.documentTitle
        lblDocumnetDescription.text = doc.documentDescription
        btnDelete.isHidden = delegate == nil
        self.delegate = delegate
    }
    
}
