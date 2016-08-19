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
	
	@IBOutlet weak var tableView: UITableView!
	var projects = [Project]()
	var selectedProject :ProjectDetail?
	
	var canPress = true
	
	var refreshControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = NSLocalizedString("Projects", comment: "")
		
		MJProgressView.instance.showProgress(self.view, white: false)
		
		if (ApplicationManager.sharedInstance.projects != nil) {
			projects = ApplicationManager.sharedInstance.projects!
			MJProgressView.instance.hideProgress()
			self.tableView.reloadData()
		} else {
			ProjectsApiCall.getCurrentProjects() { (isOk :Bool, proj :[Project]?, mess :String) in
				if (!isOk) {
					ErrorViewer.errorPresent(self, mess: mess) {}
				} else {
					self.projects = proj!
					MJProgressView.instance.hideProgress()
					self.tableView.reloadData()
				}
			}
		}
		self.refreshControl.tintColor = UIUtils.backgroundColor()
		self.refreshControl.addTarget(self, action: #selector(ProjectsViewController.refreshData(_:)), forControlEvents: .ValueChanged)
		self.tableView.addSubview(refreshControl)
		
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func refreshData(sender :AnyObject) {
		
		ProjectsApiCall.getCurrentProjects() { (isOk :Bool, proj :[Project]?, mess :String) in
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				self.projects = proj!
				self.refreshControl.endRefreshing()
				self.tableView.reloadData()
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
		
		if (projects.count == 0) {
			tableView.separatorStyle = .None
		} else {
			tableView.separatorStyle = .SingleLine
			tableView.backgroundView = nil
		}
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (projects.count == 0) {
			tableView.separatorStyle = .None
			let nibView = NSBundle.mainBundle().loadNibNamed("EmptyTableView", owner: self, options: nil)[0] as! UIView
			let titleLabel = nibView.viewWithTag(1) as! UILabel
			titleLabel.text = NSLocalizedString("NoCurrentProject", comment: "")
			tableView.backgroundView = nibView
			return 0
		}
		tableView.separatorStyle = .SingleLine
		return projects.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("projectCell")
		
		let titleProject = cell?.viewWithTag(1) as! UILabel
		let titleModule = cell?.viewWithTag(2) as! UILabel
		
		cell?.accessoryType = .DisclosureIndicator
		
		titleProject.text = projects[indexPath.row].actiTitle!
		titleModule.text = projects[indexPath.row].titleModule!
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if (!canPress) { return }
		canPress = false
		
		MJProgressView.instance.showProgress(self.view, white: false)
		tableView.userInteractionEnabled = false
		tableView.scrollEnabled = false
		ProjectsApiCall.getProjectDetails(projects[indexPath.row]) { (isOk :Bool, proj :ProjectDetail?, mess :String) in
			
			tableView.userInteractionEnabled = true
			tableView.scrollEnabled = true
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				
				self.selectedProject = proj!
				tableView.userInteractionEnabled = false
				tableView.scrollEnabled = false
				ProjectsApiCall.getProjectFiles(self.projects[indexPath.row]) { (isOk :Bool, files :[File]?, mess :String) in
					tableView.userInteractionEnabled = true
					tableView.scrollEnabled = true
					if (!isOk) {
						ErrorViewer.errorPresent(self, mess: mess) {}
					} else {
						self.selectedProject?.files = files
						self.performSegueWithIdentifier("detailsProjectSegue", sender: self)
					}
					self.canPress = true
				}
				
				
			}
			self.canPress = true
			MJProgressView.instance.hideProgress()
		}
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "detailsProjectSegue") {
			let vc :ProjectsDetailsViewController = segue.destinationViewController as! ProjectsDetailsViewController
			vc.project = selectedProject
		}
	}
	
}
