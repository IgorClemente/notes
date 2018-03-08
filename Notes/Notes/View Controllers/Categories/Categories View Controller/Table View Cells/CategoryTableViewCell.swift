//
//  CategoryTableViewCell.swift
//  Notes
//
//  Created by MACBOOK AIR on 26/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var nameCategoryLabel: UILabel?

    static let reuseIdentifier:String = "categoryCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
