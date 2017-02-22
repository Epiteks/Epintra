//
//  ProfileViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 26/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import RxSwift

class ProfileViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	var files: [File]?
	var flags: [Flags]?
	var webViewData: File?
	
	var downloadingFiles: Bool = false
	var downloadingFlags: Bool = false
	
	let sectionsTitles = [
		"",
		"Files",
		"Medals",
		"Remarkables",
		"Difficulty",
		"Ghost"
	]
	
    /// Bag
    let bag = DisposeBag()
    
    /// Subscription to the user instance
    var userSubscription: Disposable?
    
	override func viewDidLoad() {
        
        super.viewDidLoad()
        
        getUserDataIfNeeded()
        
		calls()
        
        self.tableView.register(UINib(nibName: "FlagTableViewCell", bundle: nil), forCellReuseIdentifier: "flagCell")
        self.tableView.register(UINib(nibName: "EmptyDataTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyCell")
	}
	
	override func awakeFromNib() {
		self.title = NSLocalizedString("Profile", comment: "")
	}
	
    /// Get user data if it is not complete
    func getUserDataIfNeeded() {
        
        // Check if the current user data contains all needed fields.
        // Otherwise, download it.
        if !(ApplicationManager.sharedInstance.user?.value.enoughDataForProfile() ?? false) {
            usersRequests.getCurrentUserData { _ in }
        }
        // Add subscription to user
        self.userSubscription = ApplicationManager.sharedInstance.user?.asObservable().subscribe(onNext: { [weak self] _ in
            self?.tableView.reloadSections([0], with: .automatic)
            return
        })
        
        self.userSubscription?.addDisposableTo(self.bag)
    }
    
	/*!
	All needed calls
	*/
	func calls() {
		self.callFlags()
		self.callDocuments()
	}
	
	/*!
	Fetch all flags of current user and update tableview
	*/
	func callFlags() {
		
		self.downloadingFlags = true
		
		usersRequests.getUserFlags((ApplicationManager.sharedInstance.user?.value.login)!) { (result) in
			switch (result) {
			case .success(let data):
					self.flags = data
				log.info("User flags fetched")
			case .failure(let error):
				if error.message != nil {
					ErrorViewer.errorPresent(self, mess: error.message!) { }
				}
			}
			self.downloadingFlags = false
			self.tableView.reloadData()
		}
	}
	
	/*!
	Fetch all documents of current user and update tableview
	*/
	func callDocuments() {
		
		self.downloadingFiles = true
		
		usersRequests.getUserDocuments { (result) in
			switch (result) {
            case .success(let data):
                self.files = data
			case .failure(let error):
				if error.message != nil {
					ErrorViewer.errorPresent(self, mess: error.message!) { }
				}
			}
			self.downloadingFiles = false
			self.tableView.reloadData()
		}
	}

    func open(file: File) {
        let vc = WebViewController()
        vc.file = file
        self.show(vc, sender: self)
    }
}

extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var res = 0
        
        switch section {
        case 0: // User informations
            res = 1
            break
        case 1: // Documents
            if files == nil || files?.count == 0 {
                res = 1
            } else {
                res = (files?.count)!
            }
            break
        default: // Other sections for flags
            if (flags == nil || flags![section - 2].modules.count == 0) {
                res = 1
            } else {
                res = (flags![section - 2].modules.count)
            }
        }
        return res
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if (indexPath as NSIndexPath).section == 0 { // Profile Cell, the first one
            cell = tableView.dequeueReusableCell(withIdentifier: "profileCell")!
            let profileView = cell.viewWithTag(1) as! ProfileView
            if let usr = ApplicationManager.sharedInstance.user?.value {
                profileView.setUserData(usr)
            }
            
            if let profileImageURL = ApplicationManager.sharedInstance.user?.value.imageUrl {
                profileView.userProfileImage.downloadProfileImage(fromURL: URL(string: profileImageURL)!)
            }
        } else if (indexPath as NSIndexPath).section == 1 { // Files
            cell = cellFiles((indexPath as NSIndexPath).row)
        } else { // Flags
            cell = cellFlag(indexPath)
        }
        
        return cell
    }
    
    /*!
     Returns the cell for file data
     
     - parameter index:	row index
     
     - returns: cell
     */
    func cellFiles(_ index: Int) -> UITableViewCell {
        
        if self.downloadingFiles == true {
            return cellLoading()
        }
        
        let filesCount = self.files?.count ?? 0
        
        if self.files == nil || filesCount <= 0 {
            return cellEmpty(data: "NoFile")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell")!
        
        let titleLabel = cell.viewWithTag(1) as! UILabel
        titleLabel.text = files![index].title!
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    /*!
     Returns the cell for flag data
     
     - parameter indexPath:	index
     
     - returns: cell
     */
    func cellFlag(_ indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "flagCell"
        
        if self.downloadingFlags == true {
            return cellLoading()
        }
        
        let flagsCount = self.flags?.count ?? 0
        
        if self.flags == nil || flagsCount <= 0 || self.flags![(indexPath as NSIndexPath).section - 2].modules.count <= 0 {
            return cellEmpty(data: "NoFlag")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? FlagTableViewCell
        let module = flags![(indexPath as NSIndexPath).section - 2].modules[(indexPath as NSIndexPath).row]
        
        cell?.moduleLabel.text = module.title
        cell?.gradeLabel.text = module.grade
        
        return cell!
    }
    
    /*!
     Returns the cell for empty data
     
     - parameter str:	data type
     
     - returns: cell
     */
    func cellEmpty(data str: String) -> UITableViewCell {
        
        let cellIdentifier = "emptyCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? EmptyDataTableViewCell
        
        cell?.infoLabel.text = NSLocalizedString(str, comment: "")
        
        return cell!
    }
    
    /*!
     Returns the cell for loading data
     
     - returns: cell
     */
    func cellLoading() -> UITableViewCell {
        
        let cellIdentifier = "loadingDataCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            let nib = UINib(nibName: "LoadingDataTableViewCell", bundle:nil)
            tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 110
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString(sectionsTitles[section], comment: "")
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1, let file = files?[(indexPath as NSIndexPath).row] {
            open(file: file)
        }
    }
}
