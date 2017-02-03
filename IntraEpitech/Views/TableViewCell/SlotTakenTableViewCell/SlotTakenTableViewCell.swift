//
//  SlotTakenTableViewCell.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 26/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class SlotTakenTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var userTitle: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var actionImageView: UIImageView!
    
    weak var tapDelegate: PlanningCellProtocol?
    
    weak var slotData: Slot?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setView(slot: Slot) {
        
        self.slotData = slot
        
        self.userTitle.text = slot.master?.title
        self.userEmail.text = slot.master?.login
        
        if slot.master?.login == ApplicationManager.sharedInstance.user?.login {
            self.actionImageView.image = #imageLiteral(resourceName: "Unregister")
            self.actionImageView.tintColor = UIUtils.planningRedColor
        }
        
    }
    
    func setSwipeActions() {
        let button = MGSwipeButton(title: NSLocalizedString("Add to calendar", comment: ""), backgroundColor: UIUtils.planningBlueColor, callback: { [weak self] callback -> Bool in
            if let slot = self?.slotData {
                self?.tapDelegate?.tappedCell(withSlot: slot)
            }
            return true
        })
        
        self.rightButtons = [button]
        self.rightSwipeSettings.transition = MGSwipeTransition.static
    }
}
