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
	
	@IBOutlet weak var tableView: UITableView!
	
	var modules = [Module]()
	var selectedModule: Module?
	
	var refreshControl = UIRefreshControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = NSLocalizedString("Modules", comment: "")
		
		if (ApplicationManager.sharedInstance.modules != nil) {
			modules = ApplicationManager.sharedInstance.modules!
		} else {
			MJProgressView.instance.showProgress(self.view, white: false)
			ModulesApiCalls.getRegisteredModules() { (isOk: Bool, resp: [Module]?, mess: String) in
				
				if (!isOk) {
					ErrorViewer.errorPresent(self, mess: mess) {}
				} else {
					self.modules = resp!
					ApplicationManager.sharedInstance.modules = resp!
					self.tableView.reloadData()
					MJProgressView.instance.hideProgress()
				}
			}
		}
		
		self.refreshControl.tintColor = UIUtils.backgroundColor()
		self.refreshControl.addTarget(self, action: #selector(ModulesViewController.refreshData(_:)), for: .valueChanged)
		self.tableView.addSubview(refreshControl)
		
		// Do any additional setup after loading the view.
	}
	
	func refreshData(_ sender: AnyObject) {
		ModulesApiCalls.getRegisteredModules() { (isOk: Bool, resp: [Module]?, mess: String) in
			
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				self.modules = resp!
				ApplicationManager.sharedInstance.modules = resp!
				self.tableView.reloadData()
				self.refreshControl.endRefreshing()
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if (segue.identifier == "moduleDetailSegue") {
//			let vc = segue.destination as! ModuleDetailsViewController
//			vc.module = selectedModule
		}
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if (modules.count == 0) {
			tableView.separatorStyle = .none
			return 0
		}
		tableView.separatorStyle = .singleLine
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return modules.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "moduleCell")
		
		let titleLabel = cell?.viewWithTag(1) as! UILabel
		let creditsLabel = cell?.viewWithTag(2) as! UILabel
		let gradeLabel = cell?.viewWithTag(3) as! UILabel
		
		let module = modules[(indexPath as NSIndexPath).row]
		
		creditsLabel.text = NSLocalizedString("AvailableCredits", comment: "") + module.credits!
		if (module.grade != nil) {
			gradeLabel.text = module.grade!
		}
		titleLabel.text = module.title!
		//cell!.textLabel!.text = modules![indexPath.row].title!
		cell?.accessoryType = .disclosureIndicator
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		tableView.isUserInteractionEnabled = false
		tableView.isScrollEnabled = false
		
		MJProgressView.instance.showProgress(self.view, white: false)
		ModulesApiCalls.getModule(modules[(indexPath as NSIndexPath).row]) { (isOk: Bool, resp: Module?, mess: String) in
			MJProgressView.instance.hideProgress()
			tableView.isUserInteractionEnabled = true
			tableView.isScrollEnabled = true
			if (!isOk) {
				ErrorViewer.errorPresent(self, mess: mess) {}
			} else {
				self.selectedModule = resp!
				self.performSegue(withIdentifier: "moduleDetailSegue", sender: self)
			}
		}
	}
}
