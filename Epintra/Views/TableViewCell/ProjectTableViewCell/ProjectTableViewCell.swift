//
//  ProjectTableViewCell.swift
//  Epintra
//
//  Created by Maxime Junger on 27/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moduleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
