//
//  ProfileView.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 07/09/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ProfileView: UIView {
	
	@IBOutlet private var contentView: UIView?
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
		NSBundle.mainBundle().loadNibNamed("ProfileView", owner: self, options: nil)
		guard let content = contentView else { return }
		content.frame = self.bounds
		content.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
		
		self.addSubview(content)
		self.creditsTitleLabel.text = NSLocalizedString("credits", comment: "")
		self.gpaTitleLabel.text = NSLocalizedString("gpa", comment: "")
		self.gpaCurrentTitleLabel.text = NSLocalizedString("gpa", comment: "")
		
		// Round and crop for default image
		self.userProfileImage.toCircle()
		self.userProfileImage.cropToSquare()
	}
	
	func setUserData(user: User) {
		
		self.spicesLabel.text =  user.spices!.currentSpices + " " + NSLocalizedString("spices", comment: "")
		self.logLabel.text = "Log : " + String(user.log!.timeActive)
		self.logLabel.textColor = user.log?.getColor()
		
		if user.gpa?.count <= 1 {
			gpaNumberLabel.hidden = true
			gpaTypeLabel.hidden = true
			gpaTitleLabel.hidden = true
		} else {
			let gpa = user.gpa![0]
			
			gpaTypeLabel.text = gpa.cycle
			gpaNumberLabel.text = gpa.value
		}
		
		let gpa = user.getLatestGPA()
		gpaTitleLabel.text = NSLocalizedString("gpa", comment: "")
		self.gpaCurrentNumberLabel.text = gpa.value
		self.gpaCurrentTypeLabel.text = gpa.cycle
		
		
		
		
		self.creditsNumberLabel.text = String(user.credits!)
	}
	
	func setUserImage(image: UIImage) {
		
		self.userProfileImage.image = image
		self.userProfileImage.toCircle()
		self.userProfileImage.cropToSquare()
	}
	
	
}
