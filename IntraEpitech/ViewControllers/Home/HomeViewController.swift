//
//  HomeViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class HomeViewController: LoadingDataViewController {
	
	@IBOutlet weak var alertTableView: UITableView!

	var tableFooterSave: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.alertTableView.rowHeight = UITableViewAutomaticDimension
        self.alertTableView.estimatedRowHeight = 60
	}
	
	override func awakeFromNib() {
		self.title = NSLocalizedString("Notifications", comment: "")
	}
	
    override func viewWillAppear(_ animated: Bool) {
        // No data
        if let history = ApplicationManager.sharedInstance.user?.history, history.count == 0 {
            self.addNoDataView(info: "NoNotification")
        } else {
           self.alertTableView.reloadData()
        }
	}
	
    func getNotifications() {
        
        let dispatchGroup = DispatchGroup()
        self.isFetching = true
        DispatchQueue.main.async {
            DispatchQueue.main.async(group: dispatchGroup, execute: {
                self.userDataCall(dispatchGroup)
                self.userHistoryCall(dispatchGroup)
            })
            dispatchGroup.notify(queue: DispatchQueue.global(qos: .default), execute: {
                DispatchQueue.main.async(execute: {
                    self.isFetching = false
                    self.alertTableView.reloadData()
                })
            })
        }
    }
	
	func userDataCall(_ group: DispatchGroup) {
		group.enter()
		usersRequests.getCurrentUserData { result in
			
			switch (result) {
			case .success(_):
				log.info("Get user data ok")
				break
			case .failure(let error):
				MJProgressView.instance.hideProgress()
				ErrorViewer.errorPresent(self, mess: error.message!) { }
				break
			}
			group.leave()
		}
	}
	
	func userHistoryCall(_ group: DispatchGroup) {
		group.enter()
		usersRequests.getHistory { result in
			switch (result) {
			case .success(_):
				log.info("Get user history")
				break
			case .failure(let error):
				MJProgressView.instance.hideProgress()
				if error.message != nil {
					ErrorViewer.errorPresent(self, mess: error.message!) {}
				}
				break
			}
			group.leave()
		}
	}
	
	func generateBackgroundView() {
		
		let usr = ApplicationManager.sharedInstance.user!
		
        let historyCount = usr.history?.count ?? 0
        
		if usr.history != nil && historyCount <= 0 {
			self.alertTableView.tableFooterView = UIView()
			let noData = NoDataView(info:  NSLocalizedString("NoNotification", comment: ""))
			self.alertTableView.backgroundView = noData
		} else {
			self.alertTableView.tableFooterView = self.tableFooterSave
			self.alertTableView.backgroundView = nil
		}
	}
}

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ApplicationManager.sharedInstance.user?.history?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        cell = tableView.dequeueReusableCell(withIdentifier: "alertCell")!
        
        cell.tag = (indexPath as NSIndexPath).row + 100
        
        let profileImage = cell.viewWithTag(1) as! UIImageView
        let content = cell.viewWithTag(2) as! UILabel
        let date = cell.viewWithTag(3) as! UILabel
        
        guard let history = ApplicationManager.sharedInstance.user?.history?[indexPath.row] else {
            log.error("Error history Home")
            return cell
        }

        profileImage.image = UIImage(named: "userProfile")
        
        if let profileImageURL = history.userPicture, let url = URL(string: profileImageURL) {
            profileImage.downloadProfileImage(fromURL: url)
        }
        
        profileImage.cropToSquare()
        profileImage.toCircle()
        
        content.text = history.title!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        date.text = String(format: "%@ - %@", history.userName!, history.date!.toAlertString())
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}
