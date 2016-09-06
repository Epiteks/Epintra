//
//  LoadingDataTableViewCell.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 06/09/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class LoadingDataTableViewCell: UITableViewCell {
	
	@IBOutlet private var loadingLabel: UILabel?
	@IBOutlet private var activityIndicator: UIActivityIndicatorView?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		
		loadingLabel?.text = NSLocalizedString("Loading", comment: "")
		dispatch_async(dispatch_get_main_queue(), {
			self.activityIndicator?.startAnimating()
		})
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}
