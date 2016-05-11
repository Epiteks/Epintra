//
//  ProjectsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 30/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ProjectsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var menuButton: UIBarButtonItem!
	
	@IBOutlet weak var _tableView: UITableView!
	var _projects = [Project]()
	var _selectedProject :ProjectDetail?
	
	var _canPress = true
	
	var _refreshControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = NSLocalizedString("Projects", comment: "")
		
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
			
		}
		
		MJProgressView.instance.showProgress(self.view, white: false)
		
		if (ApplicationManager.sharedInstance._projects != nil) {
			_projects = ApplicationManager.sharedInstance._projects!
			MJProgressView.instance.hideProgress()
			self._tableView.reloadData()
		}
		else {
			ProjectsApiCall.getCurrentProjects() { (isOk :Bool, proj :[Project]?, mess :String) in
				if (!isOk) {
					ErrorViewer.errorPresent(self, mess: mess) {}
				}
				else {
					self._projects = proj!
					MJProgressView.instance.hideProgress()
					self._tableView.reloadData()
				}
			}
		}
		self._refreshControl.tintColor = UIUtils.backgroundColor()
		self._refreshControl.addTarget(self, action: "refreshData:", forControlEvents: .ValueChanged)
		self._tableView.addSubview(_refreshControl)
		
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(animated: Bool) {
		
		// Google Analytics Data
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: "Projects")
		
		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
		
	}
	
	func refreshData(sender :AnyObject) {
		
		ProjectsApiCall.getCurrentProjects() { (isOk :Bool, proj :[Project]?, mess :String) in
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				self._projects = proj!
				self._refreshControl.endRefreshing()
				self._tableView.reloadData()
			}
		}
	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		if (_projects.count == 0) {
			_tableView.separatorStyle = .None
		}
		else {
			_tableView.separatorStyle = .SingleLine
			_tableView.backgroundView = nil
		}
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (_projects.count == 0) {
			tableView.separatorStyle = .None
			let nibView = NSBundle.mainBundle().loadNibNamed("EmptyTableView", owner: self, options: nil)[0] as! UIView
			let titleLabel = nibView.viewWithTag(1) as! UILabel
			titleLabel.text = NSLocalizedString("NoCurrentProject", comment: "")
			_tableView.backgroundView = nibView
			return 0
		}
		tableView.separatorStyle = .SingleLine
		return _projects.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("projectCell")
		
		let titleProject = cell?.viewWithTag(1) as! UILabel
		let titleModule = cell?.viewWithTag(2) as! UILabel
		
		cell?.accessoryType = .DisclosureIndicator
		
		titleProject.text = _projects[indexPath.row]._actiTitle!
		titleModule.text = _projects[indexPath.row]._titleModule!
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if (!_canPress) { return }
		_canPress = false
		
		MJProgressView.instance.showProgress(self.view, white: false)
		tableView.userInteractionEnabled = false
		tableView.scrollEnabled = false
		ProjectsApiCall.getProjectDetails(_projects[indexPath.row]) { (isOk :Bool, proj :ProjectDetail?, mess :String) in
			
			tableView.userInteractionEnabled = true
			tableView.scrollEnabled = true
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			}
			else {
				
				self._selectedProject = proj!
				tableView.userInteractionEnabled = false
				tableView.scrollEnabled = false
				ProjectsApiCall.getProjectFiles(self._projects[indexPath.row]) { (isOk :Bool, files :[File]?, mess :String) in
					tableView.userInteractionEnabled = true
					tableView.scrollEnabled = true
					if (!isOk) {
						ErrorViewer.errorPresent(self, mess: mess) {}
					}
					else {
						self._selectedProject?._files = files
						self.performSegueWithIdentifier("detailsProjectSegue", sender: self)
					}
					self._canPress = true
				}
				
				
			}
			self._canPress = true
			MJProgressView.instance.hideProgress()
		}
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "detailsProjectSegue") {
			let vc :ProjectsDetailsViewController = segue.destinationViewController as! ProjectsDetailsViewController
			vc._project = _selectedProject
		}
	}
	
}
