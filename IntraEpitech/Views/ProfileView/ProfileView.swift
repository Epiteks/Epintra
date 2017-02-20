//
//  ProfileView.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 07/09/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ProfileView: UIView {
	
	@IBOutlet fileprivate var contentView: UIView?
	@IBOutlet weak var logLabel: UILabel!
	@IBOutlet weak var userProfileImage: UIImageView!
	@IBOutlet weak var creditsNumberLabel: UILabel!
	@IBOutlet weak var creditsTitleLabel: UILabel! // Set here
	@IBOutlet weak var spicesLabel: UILabel!
	
	@IBOutlet weak var gpaNumberLabel: UILabel!
	@IBOutlet weak var gpaTypeLabel: UILabel!
	@IBOutlet weak var gpaTitleLabel: UILabel! // Set here
	
	@IBOutlet weak var gpaCurrentNumberLabel: UILabel!
	@IBOutlet weak var gpaCurrentTypeLabel: UILabel!
	@IBOutlet weak var gpaCurrentTitleLabel: UILabel! // Set here
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
	}
	
	func commonInit() {
		Bundle.main.loadNibNamed("ProfileView", owner: self, options: nil)
		guard let content = contentView else { return }
		content.frame = self.bounds
		content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		
		self.addSubview(content)
		self.creditsTitleLabel.text = NSLocalizedString("credits", comment: "")
		self.gpaTitleLabel.text = NSLocalizedString("gpa", comment: "")
		self.gpaCurrentTitleLabel.text = NSLocalizedString("gpa", comment: "")
		
		// Round and crop for default image
		self.userProfileImage.toCircle()
		self.userProfileImage.cropToSquare()
	}
	
	func setUserData(_ user: User) {
		
        if let spices = user.spices {
            self.spicesLabel.text =  spices.currentSpices + " " + NSLocalizedString("spices", comment: "")
        }
		
        if let log = user.log {
            self.logLabel.text = "Log:  " + String(log.timeActive)
            self.logLabel.textColor = user.log?.getColor()
        }
        
		if let gpaCount = user.gpa?.count, gpaCount <= 1 {
			gpaNumberLabel.isHidden = true
			gpaTypeLabel.isHidden = true
			gpaTitleLabel.isHidden = true
		} else {
            if let gpa = user.gpa?[0] {
                gpaTypeLabel.text = gpa.cycle
                gpaNumberLabel.text = gpa.value
            }
		}
		
		let gpa = user.getLatestGPA()
		gpaTitleLabel.text = NSLocalizedString("gpa", comment: "")
		self.gpaCurrentNumberLabel.text = gpa.value
		self.gpaCurrentTypeLabel.text = gpa.cycle
		
		self.creditsNumberLabel.text = String(user.credits ?? 0)
	}
	
	func setUserImage(_ image: UIImage) {
		
		self.userProfileImage.image = image
		self.userProfileImage.toCircle()
		self.userProfileImage.cropToSquare()
	}
	
}
