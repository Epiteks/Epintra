//
//  NoDataView.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 05/09/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class NoDataView: UIView {
	
	@IBOutlet private var contentView: UIView?
	@IBOutlet private var informationLabel: UILabel?
	
	var informationText: String?
	
	override init(frame: CGRect) { // for using CustomView in code
		super.init(frame: frame)
		self.commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
		super.init(coder: aDecoder)
		self.commonInit()
	}
	
	init(info: String) {
		informationText = info
		super.init(frame: CGRect.zero)
		commonInit()
	}
	
	private func commonInit() {
		NSBundle.mainBundle().loadNibNamed("NoDataView", owner: self, options: nil)
		guard let content = contentView else { return }
		content.frame = self.bounds
		content.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
		
		if informationText != nil {
			informationLabel?.text = informationText!
		}
		
		self.addSubview(content)
	}
}
