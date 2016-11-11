//
//  LoadingView.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 04/09/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class LoadingView: UIView {
	
	@IBOutlet fileprivate var contentView: UIView?
	@IBOutlet fileprivate var loadingLabel: UILabel?
	@IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView?
	
	override init(frame: CGRect) { // for using CustomView in code
		super.init(frame: frame)
		self.commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
		super.init(coder: aDecoder)
		self.commonInit()
	}
	
	fileprivate func commonInit() {
		Bundle.main.loadNibNamed("LoadingView", owner: self, options: nil)
		guard let content = contentView else { return }
		content.frame = self.bounds
		content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		
		loadingLabel?.text = NSLocalizedString("Loading", comment: "")
		activityIndicator?.startAnimating()
		
		self.addSubview(content)
	}
}
