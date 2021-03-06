//
//  ModuleDetailsViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 23/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ModuleDetailsViewController: LoadingDataViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var moduleProgressView: UIProgressView!
    @IBOutlet weak var moduleEndLabel: UILabel!
    @IBOutlet weak var activitiesTableView: UITableView!
    
    var barButtonItem: UIBarButtonItem!
    
    var module: Module?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = NSLocalizedString("Module", comment: "")
        
        self.barButtonItem = UIBarButtonItem(title: NSLocalizedString("Grades", comment: ""), style: .plain, target: self, action: #selector(registeredStudentsButtonTouched))
        
        navigationItem.rightBarButtonItem = self.barButtonItem
        
        setModuleEndLabel()
        setProgressView()
        
        self.activitiesTableView.register(UINib(nibName: "ModuleActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "activityCell")
        self.activitiesTableView.rowHeight = UITableViewAutomaticDimension
        self.activitiesTableView.estimatedRowHeight = 50
        self.activitiesTableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "gradesSegue" {
            if let vc = segue.destination as? ModuleRegisteredStudentsViewController {
                vc.students = self.module?.registeredStudents
            }
        } else if segue.identifier == "projectDetailsSegue" {
            if let vc = segue.destination as? ProjectDetailsViewController, let activity = sender as? Project {
                vc.project = activity
            }
        } else if segue.identifier == "projectMarksSegue" {
            if let vc = segue.destination as? ProjectMarksViewController, let marks = (sender as? Project)?.marks {
                vc.marks = marks
            }
        }
    }
    
    func setModuleEndLabel() {
        if let registerLimit = self.module?.endRegister?.shortToDate(), registerLimit > Date() {
            self.moduleEndLabel.text = NSLocalizedString("InscriptionEnd", comment: "") + registerLimit.toTitleString()
        } else if let end = self.module?.end?.shortToDate() {
            self.moduleEndLabel.text = String(format: "%@%@", end > Date() ? NSLocalizedString("ModuleEnd", comment: "") : NSLocalizedString("ModuleEndedSince", comment: ""), end.toTitleString())
        } else {
            self.moduleEndLabel.text = ""
        }
    }
    
    func setProgressView() {
        
        if let begin = self.module?.begin?.shortToDate(), let end = self.module?.end?.shortToDate() {
            
            let today = Date()
            
            let totalTime = end.timeIntervalSince(begin)
            let currentTime = end.timeIntervalSince(today)
            
            let percent = 1 - (currentTime * 100 / totalTime) / 100
            
            if end < today {
                self.moduleProgressView.setProgress(1.0, animated: true)
                self.moduleProgressView.progressTintColor = UIUtils.planningRedColor
            } else {
                self.moduleProgressView.setProgress(Float(percent), animated: true)
                if (percent > 0.8) {
                    self.moduleProgressView.progressTintColor = UIUtils.planningOrangeColor
                } else {
                    self.moduleProgressView.progressTintColor = UIUtils.planningGreenColor
                }
            }
        }
    }
    
    func getProjectFiles(forProject activity: Project, group: DispatchGroup) {
        group.enter()
        projectsRequests.files(forProject: activity, completion: { [weak self] (result) in
            switch (result) {
            case .success(let files):
                activity.files = files
            case .failure(let err):
                if let tmpSelf = self, let message = err.message {
                    ErrorViewer.errorPresent(tmpSelf, mess: message) {}
                }
                log.error("Fetching project files error:  \(err)")
            }
            group.leave()
        })
    }
    
    func getProjectDetails(forProject activity: Project, group: DispatchGroup) {
        group.enter()
        projectsRequests.details(forProject: activity, completion: { [weak self] result in
            switch (result) {
            case .success(_):
                log.info("Project details set")
                break
            case .failure(let err):
                if let tmpSelf = self, let message = err.message {
                    ErrorViewer.errorPresent(tmpSelf, mess: message) {}
                }
                log.error("Fetching project details error:  \(err)")
            }
            group.leave()
        })
    }
    
    func registeredStudentsButtonTouched() {
        self.barButtonItem.isEnabled = false
        self.addActivityIndicator()
        modulesRequests.registeredStudents(for: self.module!) { [weak self] result in

            switch (result) {
            case .success(let registeredStudents):
                self?.module?.registeredStudents = registeredStudents
                self?.performSegue(withIdentifier: "gradesSegue", sender: nil)
            case .failure(let err):
                if let tmpSelf = self, let message = err.message {
                    ErrorViewer.errorPresent(tmpSelf, mess: message) {}
                }
                log.error("Fetching modules error:  \(err)")
            }
            self?.removeActivityIndicator()
            self?.barButtonItem.isEnabled = true
        }
    }
}

extension ModuleDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.module?.activities.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "activityCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ModuleActivityTableViewCell
        
        if let activity = self.module?.activities[indexPath.row] {
            
            cell?.activityTitleLabel.text = activity.actiTitle
            cell?.markLabel.text = activity.mark
            cell?.startDateLabel.text = activity.begin?.toDate().toActiDate()
            cell?.endDateLabel.text = activity.end?.toDate().toActiDate()
            cell?.activityColor = UIUtils.activitiesColors[activity.typeActiCode!]
            cell?.moduleLabel.text = ""
            
            if let characters = activity.mark?.characters, characters.count > 0 {
                cell?.accessoryType = .disclosureIndicator
            } else if activity.typeActiCode == "proj" {
                cell?.accessoryType = .disclosureIndicator
            } else {
                cell?.accessoryType = .none
            }
            
        }
        return cell!
    }
    
}

extension ModuleDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.willLoadNextView == true { return }
        
        if let activity = self.module?.activities[indexPath.row] {
            if activity.typeActiCode == "proj" {
                self.willLoadNextView = true
                self.addActivityIndicator()
                let dispatchGroup = DispatchGroup()
                DispatchQueue.global(qos: .utility).async {
                    DispatchQueue.global(qos: .utility).async(group: dispatchGroup, execute: {
                        self.getProjectFiles(forProject: activity, group: dispatchGroup)
                        self.getProjectDetails(forProject: activity, group: dispatchGroup)
                    })
                    dispatchGroup.notify(queue: DispatchQueue.global(qos: .utility), execute: {
                        DispatchQueue.main.async(execute: {
                            self.removeActivityIndicator()
                            self.performSegue(withIdentifier: "projectDetailsSegue", sender: activity)
                            self.activitiesTableView.deselectRow(at: indexPath, animated: true)
                            self.willLoadNextView = false
                        })
                    })
                }
            } else if let characters = activity.mark?.characters, characters.count > 0 {
                self.willLoadNextView = true
                self.addActivityIndicator()
                projectsRequests.marks(forProject: activity) { [weak self] _ in
                    self?.performSegue(withIdentifier: "projectMarksSegue", sender: activity)
                    self?.willLoadNextView = false
                    self?.removeActivityIndicator()
                    self?.activitiesTableView.deselectRow(at: indexPath, animated: true)
                }
            } else {
                self.activitiesTableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
}
