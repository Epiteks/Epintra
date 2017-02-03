//
//  EventTableViewCell.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 10/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class EventTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var activityTypeView: UIView!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var moduleTitleLabel: UILabel!
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    var activityData: Planning?
    
    var activityColor: UIColor! = .black
    
    weak var tapDelegate: PlanningCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.activityTypeView.backgroundColor = self.activityColor
        
        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.activityTypeView.backgroundColor = self.activityColor
    }
    
    func setView(with data: Planning) {
        
        self.activityData = data
        
        if let eventType = data.eventTypeCode, eventType.characters.count > 0 {
            self.activityColor = UIUtils.activitiesColors[eventType]
        } else {
            self.activityColor = .red
        }
        
        self.activityTitleLabel.text = (data.actiTitle?.characters.count)! > 0 ? data.actiTitle : data.title
        
        self.moduleTitleLabel.text = String(format: "%@ - %@", data.titleModule!, data.codeInstance!)
        
        if let room = data.room, let code = room.code {
            self.moduleTitleLabel.text = "\(code) - \(self.moduleTitleLabel.text ?? "")"
        }
        
        self.startTimeLabel.text = data.startTime?.toEventHour()
        self.endTimeLabel.text = data.endTime?.toEventHour()
        
        self.setStatusImage(data: data)
        self.setSwipeActions()
    }
    
    func setStatusImage(data: Planning) {
        
        self.accessoryType = .none
        
        if (data.eventTypeCode == "rdv") {
            statusImageView.image = nil
            statusImageView.tintColor = UIUtils.planningGrayColor
            self.accessoryType = .disclosureIndicator
            return
        }
        
        if (data.canEnterToken) {
            statusImageView.image = #imageLiteral(resourceName: "Token").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningBlueColor
        } else if (data.canRegister) {
            statusImageView.image = #imageLiteral(resourceName: "Register").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningGreenColor
        } else if (data.canUnregister) {
            statusImageView.image = #imageLiteral(resourceName: "Unregister").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningRedColor
        } else if (data.isRegistered && !data.canUnregister) {
            statusImageView.image = #imageLiteral(resourceName: "Unregister").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningGrayColor
        } else if (data.isNotRegistered && !data.canRegister) {
            statusImageView.image = #imageLiteral(resourceName: "Register").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningGrayColor
        } else if (data.wasPresent) {
            statusImageView.image = #imageLiteral(resourceName: "Done").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningGreenColor
        } else if (data.wasAbsent) {
            statusImageView.image = #imageLiteral(resourceName: "Delete").withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            statusImageView.tintColor = UIUtils.planningRedColor
        } else {
            statusImageView.image = nil
        }
    }
    
    func setSwipeActions() {
        
        if self.accessoryType != .disclosureIndicator {
            
            let button = MGSwipeButton(title: NSLocalizedString("Add to calendar", comment: ""), backgroundColor: UIUtils.planningBlueColor, callback: { [weak self] callback -> Bool in
                if let data = self?.activityData {
                    self?.tapDelegate?.tappedCell(withEvent: data)
                }
                return true
            })
            
            self.rightButtons = [button]

            self.rightSwipeSettings.transition = MGSwipeTransition.static
        }
    }
}
