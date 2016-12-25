//
//  ModuleDetailsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 23/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class StudentModuleDetailsViewController: SchoolDataViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var moduleProgressView: UIProgressView!
    @IBOutlet weak var moduleEndLabel: UILabel!
    @IBOutlet weak var activitiesTableView: UITableView!
    
    var barButtonItem: UIBarButtonItem!
    
    var module: Module? = nil
    
    let typeColors = [
        "proj" : UIUtils.planningBlueColor(),
        "rdv" : UIUtils.planningOrangeColor(),
        "tp" : UIUtils.planningPurpleColor(),
        "other" : UIUtils.planningBlueColor(),
        "exam" : UIUtils.planningRedColor(),
        "class" : UIUtils.planningGreenColor()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = NSLocalizedString("Module", comment: "")
        
        self.barButtonItem = UIBarButtonItem(title: NSLocalizedString("Grades", comment: ""), style: .plain, target: self, action: #selector(registeredStudentsButtonTouched))
        
        navigationItem.rightBarButtonItem = self.barButtonItem
        
        setModuleEndLabel()
        setProgressView()
        
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
                vc.students = module?.registeredStudents
            }
        }
    }
    
    
    func setModuleEndLabel() {
        if let registerLimit = self.module?.endRegister?.shortToDate(), registerLimit > Date() {
            self.moduleEndLabel.text = NSLocalizedString("InscriptionEnd", comment: "") + registerLimit.toTitleString()
        } else if let end = self.module?.end?.shortToDate() {
            self.moduleEndLabel.text = String(format: "%@%@", end > Date() ? NSLocalizedString("ModuleEnd", comment: "") : NSLocalizedString("ModuleEndedSince", comment: ""), end.toTitleString())
        }
    }
    
    func setProgressView() {
        
        if let begin = self.module?.begin!.shortToDate(), let end = self.module?.end!.shortToDate() {
            
            let today = Date()
            
            let totalTime = end.timeIntervalSince(begin)
            let currentTime = end.timeIntervalSince(today)
            
            let percent = 1 - (currentTime * 100 / totalTime) / 100
            
            if end < today {
                self.moduleProgressView.setProgress(1.0, animated: true)
                self.moduleProgressView.progressTintColor = UIUtils.planningRedColor()
            } else {
                self.moduleProgressView.setProgress(Float(percent), animated: true)
                if (percent > 0.8) {
                    self.moduleProgressView.progressTintColor = UIUtils.planningOrangeColor()
                } else {
                    self.moduleProgressView.progressTintColor = UIUtils.planningGreenColor()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let activities = self.module?.activities {
            return activities.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "activityCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ModuleActivityTableViewCell
        
        if cell == nil {
            let nib = UINib(nibName: "ModuleActivityTableViewCell", bundle:nil)
            tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ModuleActivityTableViewCell
        }
        
        if let activity = self.module?.activities[indexPath.row] {
            
            cell?.activityTitleLabel.text = activity.actiTitle
            
            cell?.markLabel.text = activity.mark
            cell?.startDateLabel.text = activity.beginActi?.toDate().toActiDate()
            cell?.endDateLabel.text = activity.endActi?.toDate().toActiDate()
            
            cell?.activityColor = self.typeColors[activity.typeActiCode!]
            
            if let characters = activity.mark?.characters, characters.count > 0 {
                cell?.accessoryType = .disclosureIndicator
            }
            
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let activity = self.module?.activities[indexPath.row], let characters = activity.mark?.characters, characters.count > 0 {
            self.addActivityIndicator()
            projectRequests.details(forProject: activity, completion: { result in
                switch (result) {
                case .success(let data):
                    
                    
                    //self.performSegue(withIdentifier: "gradesSegue", sender: self)
                    break
                case .failure(let err):
                    if err.message != nil {
                        ErrorViewer.errorPresent(self, mess: err.message!) {}
                    }
                    log.error("Fetching project details error : \(err)")
                }
                self.removeActivityIndicator()
                self.barButtonItem.isEnabled = true
            })
            
        }
        
    }
    
    func registeredStudentsButtonTouched() {
        self.barButtonItem.isEnabled = false
        self.addActivityIndicator()
        modulesRequests.registeredStudents(for: self.module!) { result in
            switch (result) {
            case .success(let registeredStudents):
                
                self.module?.registeredStudents = registeredStudents
                self.performSegue(withIdentifier: "gradesSegue", sender: self)
            case .failure(let err):
                if err.message != nil {
                    ErrorViewer.errorPresent(self, mess: err.message!) {}
                }
                log.error("Fetching modules error : \(err)")
            }
            self.removeActivityIndicator()
            self.barButtonItem.isEnabled = true
            
        }
    }
    
}

