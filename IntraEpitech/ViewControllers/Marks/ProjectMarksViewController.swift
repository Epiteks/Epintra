//
//  ProjectMarksViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 01/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ProjectMarksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var _marks :[Mark]?
	var _selectedMark :Mark?
	
	@IBOutlet weak var _tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = NSLocalizedString("Marks", comment: "")
		
		// Do any additional setup after loading the view.
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .Plain, target: self, action: (#selector(ProjectMarksViewController.backButtonAction(_:))))
		self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
		
		self.navigationItem.setHidesBackButton(true, animated: false)
		self.navigationItem.backBarButtonItem = nil
		
	}
	
	func backButtonAction(sender :AnyObject) {
		self.navigationController?.popViewControllerAnimated(true)
	}

	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		
		var index :NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
		
		var i = 0
		
		for tmp in _marks! {
			if (tmp._login == ApplicationManager.sharedInstance._currentLogin!) {
				index = NSIndexPath(forRow: i, inSection: 0)
				break
			}
			i += 1
		}
		
		_tableView.scrollToRowAtIndexPath(index, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "commentsSegue") {
			let vc = segue.destinationViewController as! CommentsViewController
			vc._mark = _selectedMark
		}
	}
	
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if (_marks == nil || _marks!.count == 0) {
			tableView.separatorStyle = .None
			let nibView = NSBundle.mainBundle().loadNibNamed("EmptyTableView", owner: self, options: nil)[0] as! UIView
			let titleLabel = nibView.viewWithTag(1) as! UILabel
			titleLabel.text = NSLocalizedString("NoMarks", comment: "")
			tableView.backgroundView = nibView
			return 0
		}
		tableView.separatorStyle = .SingleLine
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _marks!.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("markCell")
		
		let user = cell?.viewWithTag(1) as! UILabel
		let mark = cell?.viewWithTag(2) as! UILabel
		
		user.text = _marks![indexPath.row]._login
		mark.text = _marks![indexPath.row]._finalNote
		
		if (_marks![indexPath.row]._login == ApplicationManager.sharedInstance._currentLogin) {
			user.textColor = UIColor.redColor()
			mark.textColor = UIColor.redColor()
		} else {
			user.textColor = UIColor.blackColor()
			mark.textColor = UIColor.blackColor()
		}
		
		cell?.accessoryType = .DisclosureIndicator
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		_selectedMark = _marks![indexPath.row]
		performSegueWithIdentifier("commentsSegue", sender: self)
	}
}
