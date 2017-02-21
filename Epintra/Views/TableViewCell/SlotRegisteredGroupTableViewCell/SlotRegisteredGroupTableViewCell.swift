//
//  SlotRegisteredGroupTableViewCell.swift
//  Epintra
//
//  Created by Maxime Junger on 28/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class SlotRegisteredGroupTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var userTitle: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var members: UILabel!
    
    @IBOutlet weak var actionImageView: UIImageView!
    
    @IBOutlet weak var stackViewToStatusImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewToSuperViewConstraint: NSLayoutConstraint!
    
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
        
        var membersString: String?
        
        if slot.members != nil {
            
            membersString = ""
            
            for member in slot.members! {
                
                // Add - to separate people
                if membersString! != "" {
                    membersString = "\(membersString!) - "
                }
                membersString = "\(membersString!) \(member.login)"
            }
        }
        
        self.members.text = membersString
        
        if slot.canUnregister {
            self.actionImageView.image = UIImage(named: "Unregister")?.withRenderingMode(.alwaysTemplate)
            self.actionImageView.tintColor = UIUtils.planningRedColor
            
            self.stackViewToStatusImageConstraint.constant = 15
            self.stackViewToSuperViewConstraint.priority = 250
            self.stackViewToStatusImageConstraint.priority = 1000
        } else {
            self.stackViewToSuperViewConstraint.constant = 15
            self.stackViewToSuperViewConstraint.priority = 1000
            self.stackViewToStatusImageConstraint.priority = 250
        }
        
        setSwipeActions()
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
