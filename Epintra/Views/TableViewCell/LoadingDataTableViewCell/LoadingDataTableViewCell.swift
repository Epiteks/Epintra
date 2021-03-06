//
//  LoadingDataTableViewCell.swift
//  Epintra
//
//  Created by Maxime Junger on 06/09/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class LoadingDataTableViewCell: UITableViewCell {
	
	@IBOutlet fileprivate var loadingLabel: UILabel?
	@IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		
		loadingLabel?.text = NSLocalizedString("Loading", comment: "")
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}
