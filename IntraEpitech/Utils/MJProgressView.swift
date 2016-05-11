//
//  MJProgressView.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 16/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class MJProgressView {
	
	static let	  instance = MJProgressView()
	
	internal var  containerView = UIView()
	internal var  progressView = UIView()
	internal var  indicator = UIActivityIndicatorView()
	
	internal var  _containerBackgroundColor :UIColor? = UIColor.whiteColor().colorWithAlphaComponent(0.3)
	internal var  _progressBackgroundColor :UIColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
	
	internal var  _isRunning = false
	
	private init() { }
	
	
	internal func showProgress(view: UIView, white : Bool) {
		_isRunning = true
		
		indicator.frame = CGRectMake(view.frame.width / 2 - 20, view.frame.height / 2 - 20, 40, 40)
		indicator.activityIndicatorViewStyle = .WhiteLarge
		indicator.color = (white == true ? UIColor.whiteColor() : UIColor.blackColor())
		//		indicator.center = CGPointMake(progressView.bounds.width / 2, progressView.bounds.height / 2)
		
		view.addSubview(indicator)
		
		indicator.startAnimating()
	}
	
	internal func showLoginProgress(view: UIView, white : Bool) {
		_isRunning = true
		
		indicator.frame = CGRectMake(view.frame.width - 30, view.frame.height / 2 - 10, 20, 20)
		indicator.activityIndicatorViewStyle = .White
		indicator.color = (white == true ? UIColor.whiteColor() : UIColor.blackColor())
		//indicator.center = CGPointMake(progressView.bounds.width / 2, progressView.bounds.height / 2)
		
		//progressView.addSubview(indicator)
		//containerView.addSubview(progressView)
		
		view.addSubview(indicator)
		
		indicator.startAnimating()
	}
	
	internal func showCellProgress(view: UIView) {
		_isRunning = true
		
		indicator.frame = CGRectMake(view.frame.width - 35, view.frame.height / 2 - 10, 20, 20)
		indicator.activityIndicatorViewStyle = .White
		indicator.color = UIUtils.backgroundColor()
		//indicator.center = CGPointMake(progressView.bounds.width / 2, progressView.bounds.height / 2)
		
		//progressView.addSubview(indicator)
		//containerView.addSubview(progressView)
		
		view.addSubview(indicator)
		
		indicator.startAnimating()
	}
	
	
	internal func hideProgress() {
		_isRunning = false
		indicator.stopAnimating()
		containerView.removeFromSuperview()
	}
	
	func setColorProperties(backgroundColor :UIColor?, progressViewBackgroundColor :UIColor) {
		_containerBackgroundColor = backgroundColor
		_progressBackgroundColor = progressViewBackgroundColor
	}
	
	func isRunning() -> Bool {
		return _isRunning
	}
}
