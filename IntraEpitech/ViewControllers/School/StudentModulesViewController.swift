//
//  ModulesViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

import DZNEmptyDataSet

class StudentModulesViewController: SchoolDataViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var modulesTableView: UITableView!

    var modules: [Module]? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getModules()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getModules() {
        
        self.isFetching = true
        
        modulesRequests.usersModules() { (result) in
            switch result {
            case .success(let data):
                
                log.info("User modules fetched")
                self.modules = data
                self.modulesTableView.reloadData()
                
                break
            case .failure(let error):
                if error.message != nil {
                    ErrorViewer.errorPresent(self, mess: error.message!) { }
                }
                break
            }
            self.isFetching = false
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
