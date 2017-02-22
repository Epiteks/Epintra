//
//  CurrentProjectsViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 27/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class CurrentProjectsViewController: LoadingDataViewController {

    @IBOutlet weak var projectsTableView: UITableView!

    var projects: [Project]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.projectsTableView.register(UINib(nibName: "ModuleActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "activityCell")
        self.projectsTableView.rowHeight = UITableViewAutomaticDimension
        self.projectsTableView.estimatedRowHeight = 60
        self.projectsTableView.separatorInset = .zero
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if ApplicationManager.sharedInstance.user?.value.projects == nil {
            getProjects()
        }
    }
    
    func getProjects() {
        self.isFetching = true
        projectsRequests.current { (result) in
            switch result {
            case .success(let data):
                self.projects = data
                ApplicationManager.sharedInstance.user?.value.projects = data
                self.projectsTableView.reloadData()
                self.removeNoDataView()
            case .failure(let error):
                if error.message != nil {
                    ErrorViewer.errorPresent(self, mess: error.message!) { }
                }
                if self.projects == nil || self.projects?.count == 0 {
                    self.addNoDataView(info: "Empty")
                }
            }
            self.isFetching = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "projectDetailsSegue" {
            if let vc = segue.destination as? ProjectDetailsViewController, let index = self.projectsTableView.indexPathForSelectedRow?.row, let project = self.projects?[index] {
                vc.project = project
            }
        }
    }
    
    func getProjectFiles(forProject activity: Project, group: DispatchGroup) {
        group.enter()
        projectsRequests.files(forProject: activity, completion: { (result) in
            switch (result) {
            case .success(let files):
                activity.files = files
            case .failure(let err):
                if err.message != nil {
                    ErrorViewer.errorPresent(self, mess: err.message!) {}
                }
                log.error("Fetching project files error:  \(err)")
            }
            group.leave()
        })
    }
    
    func getProjectDetails(forProject activity: Project, group: DispatchGroup) {
        group.enter()
        projectsRequests.details(forProject: activity, completion: { result in
            switch (result) {
            case .success(_):
                log.info("Project details set")
                break
            case .failure(let err):
                if err.message != nil {
                    ErrorViewer.errorPresent(self, mess: err.message!) {}
                }
                log.error("Fetching project details error:  \(err)")
            }
            group.leave()
        })
    }
}

extension CurrentProjectsViewController: UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.projects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "activityCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ModuleActivityTableViewCell
        
        if let data = self.projects?[indexPath.row] {
            cell?.activityTitleLabel.text = data.actiTitle
            cell?.moduleLabel.text = data.titleModule
            cell?.activityColor = UIUtils.planningBlueColor
            cell?.markLabel.text = ""
            cell?.startDateLabel.text = data.begin?.toDate().toActiDate()
            cell?.endDateLabel.text = data.end?.toDate().toActiDate()
            cell?.accessoryType = .disclosureIndicator
        }
        return cell!
    }
}

extension CurrentProjectsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if self.willLoadNextView == true { return }
        
        if let project = self.projects?[indexPath.row] {
            self.willLoadNextView = true
            self.addActivityIndicator()
            let dispatchGroup = DispatchGroup()
            DispatchQueue.global(qos: .utility).async {
                DispatchQueue.global(qos: .utility).async(group: dispatchGroup, execute: {
                    self.getProjectFiles(forProject: project, group: dispatchGroup)
                    self.getProjectDetails(forProject: project, group: dispatchGroup)
                })
                dispatchGroup.notify(queue: DispatchQueue.global(qos: .utility), execute: {
                    DispatchQueue.main.async(execute: {
                        self.removeActivityIndicator()
                        self.performSegue(withIdentifier: "projectDetailsSegue", sender: self)
                        tableView.deselectRow(at: indexPath, animated: true)
                        self.willLoadNextView = false
                    })
                })
            }
        }
    }
}
