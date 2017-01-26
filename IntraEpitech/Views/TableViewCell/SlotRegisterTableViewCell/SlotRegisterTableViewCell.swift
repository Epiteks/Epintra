//
//  SlotRegisterTableViewCell.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 26/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit

class SlotRegisterTableViewCell: UITableViewCell {

    @IBOutlet weak var registerText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.registerText.text = NSLocalizedString("Register", comment: "")
        self.registerText.textColor = UIUtils.planningGreenColor
        self.registerText.font = UIFont.boldSystemFont(ofSize: 17)
       }

}
