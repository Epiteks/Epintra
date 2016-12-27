//
//  ProjectMarksViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 01/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ProjectMarkssViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var marks: [Mark]?
	var selectedMark: Mark?
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = NSLocalizedString("Marks", comment: "")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		var index: IndexPath = IndexPath(row: 0, section: 0)
		
		var i = 0
		
		for tmp in marks! {
			if (tmp.login == ApplicationManager.sharedInstance.currentLogin!) {
				index = IndexPath(row: i, section: 0)
				break
			}
			i += 1
		}
		
		tableView.scrollToRow(at: index, at: UITableViewScrollPosition.top, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "commentsSegue") {
			let vc = segue.destination as! CommentsViewController
			vc.mark = selectedMark
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if (marks == nil || marks!.count == 0) {
			tableView.separatorStyle = .none
			let nibView = Bundle.main.loadNibNamed("EmptyTableView", owner: self, options: nil)?[0] as! UIView
			let titleLabel = nibView.viewWithTag(1) as! UILabel
			titleLabel.text = NSLocalizedString("NoMarks", comment: "")
			tableView.backgroundView = nibView
			return 0
		}
		tableView.separatorStyle = .singleLine
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return marks!.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "markCell")
		
		let user = cell?.viewWithTag(1) as! UILabel
		let mark = cell?.viewWithTag(2) as! UILabel
		
		user.text = marks![(indexPath as NSIndexPath).row].login
		mark.text = marks![(indexPath as NSIndexPath).row].finalNote
		
		if (marks![(indexPath as NSIndexPath).row].login == ApplicationManager.sharedInstance.currentLogin) {
			user.textColor = UIColor.red
			mark.textColor = UIColor.red
		} else {
			user.textColor = UIColor.black
			mark.textColor = UIColor.black
		}
		
		cell?.accessoryType = .disclosureIndicator
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		selectedMark = marks![(indexPath as NSIndexPath).row]
		performSegue(withIdentifier: "commentsSegue", sender: self)
	}
}
