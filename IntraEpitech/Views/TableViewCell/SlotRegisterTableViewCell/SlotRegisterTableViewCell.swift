//
//  SlotRegisterTableViewCell.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 26/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class SlotRegisterTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var registerText: UILabel!
    
    weak var tapDelegate: PlanningCellProtocol? = nil
    
    weak var slotData: Slot? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.registerText.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    func setView(slot: Slot) {
        
        self.slotData = slot
        
        // Slot open and available. Current user not registered in another event and the slot is in the future
        if slot.canRegister && (slot.appointment?.canRegister ?? false) {
            self.registerText.text = NSLocalizedString("Register", comment: "")
            self.registerText.textColor = UIUtils.planningGreenColor
        } else {
            self.registerText.text = "🔒"
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
