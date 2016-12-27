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
	
	internal var  _containerBackgroundColor: UIColor? = UIColor.white.withAlphaComponent(0.3)
	internal var  _progressBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.7)
	
	internal var  _isRunning = false
	
	fileprivate init() { }
	
	internal func showProgress(_ view: UIView, white:  Bool) {
		_isRunning = true
		
		indicator.frame = CGRect(x: view.frame.width / 2 - 20, y: view.frame.height / 2 - 20, width: 40, height: 40)
		indicator.activityIndicatorViewStyle = .whiteLarge
		indicator.color = (white == true ? UIColor.white:  UIColor.black)
		//		indicator.center = CGPointMake(progressView.bounds.width / 2, progressView.bounds.height / 2)
		
		view.addSubview(indicator)
		
		indicator.startAnimating()
	}
	
	internal func showLoginProgress(_ view: UIView, white:  Bool) {
		_isRunning = true
		
		indicator.frame = CGRect(x: view.frame.width - 30, y: view.frame.height / 2 - 10, width: 20, height: 20)
		indicator.activityIndicatorViewStyle = .white
		indicator.color = (white == true ? UIColor.white:  UIColor.black)
		//indicator.center = CGPointMake(progressView.bounds.width / 2, progressView.bounds.height / 2)
		
		//progressView.addSubview(indicator)
		//containerView.addSubview(progressView)
		
		view.addSubview(indicator)
		
		indicator.startAnimating()
	}
	
	internal func showCellProgress(_ view: UIView) {
		_isRunning = true
		
		indicator.frame = CGRect(x: view.frame.width - 35, y: view.frame.height / 2 - 10, width: 20, height: 20)
		indicator.activityIndicatorViewStyle = .white
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
	
	func setColorProperties(_ backgroundColor: UIColor?, progressViewBackgroundColor: UIColor) {
		_containerBackgroundColor = backgroundColor
		_progressBackgroundColor = progressViewBackgroundColor
	}
	
	func isRunning() -> Bool {
		return _isRunning
	}
}
