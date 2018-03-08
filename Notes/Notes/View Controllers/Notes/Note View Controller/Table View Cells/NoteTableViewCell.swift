//
//  NoteTableViewCell.swift
//  Notes
//
//  Created by MACBOOK AIR on 18/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    static let reuseIdentifier = "NoteTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var contentsLabel: UILabel?
    @IBOutlet weak var updateAtLabel: UILabel?
    @IBOutlet weak var tagsLabel: UILabel?
    
    @IBOutlet weak var categoryColorView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
