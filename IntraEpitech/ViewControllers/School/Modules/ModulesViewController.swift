//
//  ModulesViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ModulesViewController: LoadingDataViewController {
    
    @IBOutlet weak var modulesTableView: UITableView!
    
    var modules: [Module]? = nil
    
    override func viewDidLoad() {
        self.modulesTableView.rowHeight = UITableViewAutomaticDimension
        self.modulesTableView.estimatedRowHeight = 60
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ApplicationManager.sharedInstance.user?.modules == nil {
            getModules()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moduleDetailsSegue" {
            if let vc = segue.destination as? ModuleDetailsViewController {
                if let selectedIndex = self.modulesTableView.indexPathForSelectedRow?.row, let module = self.modules?[selectedIndex] {
                    vc.module = module
                }
            }
        }
    }
    
    func getModules() {
        
        self.isFetching = true
        
        modulesRequests.usersModules { (result) in
            switch result {
            case .success(let data):
                log.info("User modules fetched")
                self.modules = data
                ApplicationManager.sharedInstance.user?.modules = data
                self.modulesTableView.reloadData()
                self.removeNoDataView()
                break
            case .failure(let error):
                if error.message != nil {
                    ErrorViewer.errorPresent(self, mess: error.message!) { }
                }
                if self.modules == nil || self.modules?.count == 0 {
                    self.addNoDataView()
                }
                break
            }
            self.isFetching = false
        }
    }
}

extension ModulesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modules?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "moduleCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ModuleTableViewCell
        
        if cell == nil {
            let nib = UINib(nibName: "ModuleTableViewCell", bundle:nil)
            tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ModuleTableViewCell
        }
        
        if let data = modules?[indexPath.row] {
            cell?.titleLabel.text = data.title
            cell?.creditsAvailableLabel.text = NSLocalizedString("AvailableCredits", comment: "") + data.credits!
            if (data.grade != nil) {
                cell?.gradeLabel.text = data.grade!
            }
            cell?.accessoryType = .disclosureIndicator
        }
        return cell ?? UITableViewCell()
    }
    
}

extension ModulesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.willLoadNextView == false {
            self.willLoadNextView = true
            self.addActivityIndicator()
            if let selectedIndex = self.modulesTableView.indexPathForSelectedRow?.row, let module = self.modules?[selectedIndex] {
                module.getDetails { _ in
                    self.performSegue(withIdentifier: "moduleDetailsSegue", sender: self)
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.removeActivityIndicator()
                    self.willLoadNextView = false
                }
            }
        }
    }
    
}
