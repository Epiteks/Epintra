//
//  ProfileView.swift
//  Epintra
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
	
	/**
     * GPA values for the previous cycle if available
    **/
	@IBOutlet weak var gpaNumberLabel: UILabel!
	@IBOutlet weak var gpaTypeLabel: UILabel!
	@IBOutlet weak var gpaTitleLabel: UILabel! // Set here
	
    /**
     * GPA values for the current cycle
     */
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
		
        self.spicesLabel.text =  String(format: "%i %@", user.spices?.currentSpices ?? 0, NSLocalizedString("spices", comment: ""))
		
        if let log = user.log {
            self.logLabel.text = "Log:  " + String(log.timeActive)
            self.logLabel.textColor = user.log?.getColor()
        } else {
            self.logLabel.text = "Log: 0"
        }
        // Hide previous GPA if the value does not exist
        if  user.gpa?.count == nil || (user.gpa?.count ?? 0) <= 1 {
			self.gpaNumberLabel.isHidden = true
			self.gpaTypeLabel.isHidden = true
			self.gpaTitleLabel.isHidden = true
        } else if let gpa = user.gpa?[0] {
            self.gpaTypeLabel.text = gpa.cycle
            self.gpaNumberLabel.text = String(gpa.value)
        }
		
        // Set current GPA values
		let gpa = user.getLatestGPA()
		self.gpaCurrentNumberLabel.text = String(gpa.value)
		self.gpaCurrentTypeLabel.text = gpa.cycle
		
		self.creditsNumberLabel.text = String(user.credits ?? 0)
	}
	
	func setUserImage(_ image: UIImage) {
		
		self.userProfileImage.image = image
		self.userProfileImage.toCircle()
		self.userProfileImage.cropToSquare()
	}
	
}
