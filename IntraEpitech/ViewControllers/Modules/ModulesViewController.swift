//
//  ModulesViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ModulesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var menuButton: UIBarButtonItem!
	
	@IBOutlet weak var _tableView: UITableView!
	
	var _modules = [Module]()
	var _selectedModule :Module?
	
	var _refreshControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
		self.title = NSLocalizedString("Modules", comment: "")
		
		if (ApplicationManager.sharedInstance._modules != nil) {
			_modules = ApplicationManager.sharedInstance._modules!
		}
		else {
			MJProgressView.instance.showProgress(self.view, white: false)
			ModulesApiCalls.getRegisteredModules() { (isOk :Bool, resp :[Module]?, mess :String) in
				
				if (!isOk) {
					ErrorViewer.errorPresent(self, mess: mess) {}
				}
				else {
					self._modules = resp!
					ApplicationManager.sharedInstance._modules = resp!
					self._tableView.reloadData()
					MJProgressView.instance.hideProgress()
				}
			}
		}
		
		self._refreshControl.tintColor = UIUtils.backgroundColor()
		self._refreshControl.addTarget(self, action: #selector(ModulesViewController.refreshData(_:)), forControlEvents: .ValueChanged)
		self._tableView.addSubview(_refreshControl)
		
		// Do any additional setup after loading the view.
	}
	
	func refreshData(sender :AnyObject) {
		ModulesApiCalls.getRegisteredModules() { (isOk :Bool, resp :[Module]?, mess :String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				self._modules = resp!
				ApplicationManager.sharedInstance._modules = resp!
				self._tableView.reloadData()
				self._refreshControl.endRefreshing()
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(animated: Bool) {
		
		// Google Analytics Data
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: "Modules")
		
		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if (segue.identifier == "moduleDetailSegue") {
			let vc = segue.destinationViewController as! ModuleDetailsViewController
			vc._module = _selectedModule
		}
		
	}
	
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if (_modules.count == 0) {
			tableView.separatorStyle = .None
			return 0
		}
		tableView.separatorStyle = .SingleLine
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _modules.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("moduleCell")
		
		let titleLabel = cell?.viewWithTag(1) as! UILabel
		let creditsLabel = cell?.viewWithTag(2) as! UILabel
		let gradeLabel = cell?.viewWithTag(3) as! UILabel
		
		let module = _modules[indexPath.row]
		
		
		creditsLabel.text = NSLocalizedString("AvailableCredits", comment: "") + module._credits!
		if (module._grade != nil) {
			gradeLabel.text = module._grade!
		}
		titleLabel.text = module._title!
		//cell!.textLabel!.text = _modules![indexPath.row]._title!
		cell?.accessoryType = .DisclosureIndicator
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		tableView.userInteractionEnabled = false
		tableView.scrollEnabled = false
		
		MJProgressView.instance.showProgress(self.view, white: false)
		ModulesApiCalls.getModule(_modules[indexPath.row]) { (isOk :Bool, resp :Module?, mess :String) in
			MJProgressView.instance.hideProgress()
			tableView.userInteractionEnabled = true
			tableView.scrollEnabled = true
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				self._selectedModule = resp!
				self.performSegueWithIdentifier("moduleDetailSegue", sender: self)
			}
		}
	}
}
