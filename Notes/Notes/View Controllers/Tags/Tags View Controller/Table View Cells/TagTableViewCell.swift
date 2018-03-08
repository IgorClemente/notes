//
//  TagTableViewCell.swift
//  Notes
//
//  Created by MACBOOK AIR on 02/03/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit

class TagTableViewCell: UITableViewCell {

    @IBOutlet weak var tagName: UILabel?
    
    static let reuseIdentifier: String = "tagCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
