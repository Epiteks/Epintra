//
//  FlagTableViewCell.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 06/09/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class FlagTableViewCell: UITableViewCell {
	
	@IBOutlet weak var moduleLabel: UILabel!
	@IBOutlet weak var gradeLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}
