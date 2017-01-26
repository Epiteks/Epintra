//
//  SlotTakenTableViewCell.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 26/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit

class SlotTakenTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userTitle: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var actionImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setView(slot: Slot) {
        self.userTitle.text = slot.master?.title
        self.userEmail.text = slot.master?.login
    }
    
}
