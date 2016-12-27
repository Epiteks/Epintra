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
	var selectedProject: ProjectDetail?
	
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
			ProjectsApiCall.getCurrentProjects() { (isOk: Bool, proj: [Project]?, mess: String) in
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
		self.refreshControl.addTarget(self, action: #selector(ProjectsViewController.refreshData(_:)), for: .valueChanged)
		self.tableView.addSubview(refreshControl)
		
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func refreshData(_ sender: AnyObject) {
		
		ProjectsApiCall.getCurrentProjects() { (isOk: Bool, proj: [Project]?, mess: String) in
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
	
	func numberOfSections(in tableView: UITableView) -> Int {
		
		if (projects.count == 0) {
			tableView.separatorStyle = .none
		} else {
			tableView.separatorStyle = .singleLine
			tableView.backgroundView = nil
		}
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (projects.count == 0) {
			tableView.separatorStyle = .none
			let nibView = Bundle.main.loadNibNamed("EmptyTableView", owner: self, options: nil)?[0] as! UIView
			let titleLabel = nibView.viewWithTag(1) as! UILabel
			titleLabel.text = NSLocalizedString("NoCurrentProject", comment: "")
			tableView.backgroundView = nibView
			return 0
		}
		tableView.separatorStyle = .singleLine
		return projects.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell")
		
		let titleProject = cell?.viewWithTag(1) as! UILabel
		let titleModule = cell?.viewWithTag(2) as! UILabel
		
		cell?.accessoryType = .disclosureIndicator
		
		titleProject.text = projects[(indexPath as NSIndexPath).row].actiTitle!
		titleModule.text = projects[(indexPath as NSIndexPath).row].titleModule!
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		if (!canPress) { return }
		canPress = false
		
		MJProgressView.instance.showProgress(self.view, white: false)
		tableView.isUserInteractionEnabled = false
		tableView.isScrollEnabled = false
		ProjectsApiCall.getProjectDetails(projects[(indexPath as NSIndexPath).row]) { (isOk: Bool, proj: ProjectDetail?, mess: String) in
			
			tableView.isUserInteractionEnabled = true
			tableView.isScrollEnabled = true
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				
				self.selectedProject = proj!
				tableView.isUserInteractionEnabled = false
				tableView.isScrollEnabled = false
				ProjectsApiCall.getProjectFiles(self.projects[(indexPath as NSIndexPath).row]) { (isOk: Bool, files: [File]?, mess: String) in
					tableView.isUserInteractionEnabled = true
					tableView.isScrollEnabled = true
					if (!isOk) {
						ErrorViewer.errorPresent(self, mess: mess) {}
					} else {
						self.selectedProject?.files = files
						self.performSegue(withIdentifier: "detailsProjectSegue", sender: self)
					}
					self.canPress = true
				}
				
			}
			self.canPress = true
			MJProgressView.instance.hideProgress()
		}
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "detailsProjectSegue") {
			let vc: ProjectsDetailsViewController = segue.destination as! ProjectsDetailsViewController
			vc.project = selectedProject
		}
	}
	
}
