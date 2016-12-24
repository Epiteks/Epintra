//
//  ModuleActivityTableViewCell.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 23/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ModuleActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var activityType: UIView!
    
    var activityColor: UIColor! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        activityType.backgroundColor = self.activityColor
    
        // Configure the view for the selected state
    }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        activityType.backgroundColor = self.activityColor
    }
}
