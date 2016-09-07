//
//  ProfileTableViewCell.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 05/09/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
	
	var profileImageView :UIImageView!
	var creditsTitleLabel :UILabel!
	var creditsLabel :UILabel!
	var spicesLabel :UILabel!
	var logLabel :UILabel!
	var gpaTitleLabel :UILabel!
	var gpaLabel :UILabel!
	var	gpaTypeLabel :UILabel!
	var currentUser :User?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		
		currentUser = ApplicationManager.sharedInstance.user
		
		loadProfileView()
		//setUIElements()
		self.backgroundColor = UIColor.yellowColor()
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
	
	func loadProfileView() {
		
		let profileV = ProfileView(frame: self.frame)
		
		//profileV.frame = self.frame
		profileV.backgroundColor = UIColor.redColor()
		
		self.addSubview(profileV)
		
		//		let nibView = NSBundle.mainBundle().loadNibNamed("ProfileView", owner: self, options: nil)[0] as! UIView
		//		nibView.frame = self.frame
		//		self.addSubview(nibView)
		//		
		//		profileImageView = nibView.viewWithTag(1) as? UIImageView
		//		creditsTitleLabel = nibView.viewWithTag(2) as? UILabel!
		//		creditsLabel = nibView.viewWithTag(3) as? UILabel!
		//		spicesLabel = nibView.viewWithTag(4) as? UILabel!
		//		logLabel = nibView.viewWithTag(5) as? UILabel!
		//		gpaTitleLabel = nibView.viewWithTag(6) as? UILabel!
		//		gpaLabel = nibView.viewWithTag(7) as? UILabel!
		//		gpaTypeLabel = nibView.viewWithTag(8) as? UILabel!
	}
	
	//	func setUIElements() {
	//		
	//		if let img = ApplicationManager.sharedInstance.downloadedImages![(ApplicationManager.sharedInstance.user?.imageUrl!)!] {
	//			self.profileImageView.image = img
	//		}
	//		
	//		self.profileImageView.cropToSquare()
	//		self.profileImageView.toCircle()
	//		
	//		
	//		creditsTitleLabel.text = NSLocalizedString("credits", comment: "")
	//		creditsLabel.text = String(currentUser!.credits!)
	//		spicesLabel.text =  currentUser!.spices!.currentSpices + " " + NSLocalizedString("spices", comment: "")
	//		logLabel.text = "Log : " + String(currentUser!.log!.timeActive)
	//		logLabel.textColor = currentUser?.log?.getColor()
	//		
	//		
	//		//		let singleTap = UITapGestureRecognizer(target: self, action:#selector(ProfileViewController.gpaTapDetected(_:)))
	//		//		singleTap.numberOfTapsRequired = 1
	//		//		gpaLabel.userInteractionEnabled = true
	//		//		gpaLabel.addGestureRecognizer(singleTap)
	//		//		
	//		let gpa = currentUser?.getLatestGPA()
	//		gpaTitleLabel.text = NSLocalizedString("gpa", comment: "")
	//		gpaLabel.text = gpa?.value
	//		gpaTypeLabel.text = gpa?.cycle
	//		
	//		
	//	}
	//	
}
