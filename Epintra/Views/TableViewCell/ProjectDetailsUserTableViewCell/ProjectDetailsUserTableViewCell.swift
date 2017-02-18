//
//  ProjectDetailsUserTableViewCell.swift
//  Epintra
//
//  Created by Maxime Junger on 17/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit

class ProjectDetailsUserTableViewCell: UITableViewCell {
   
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
