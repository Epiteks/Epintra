//
//  PlanningFilterViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 11/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit

class PlanningFilterViewController: UIViewController {

    struct PlanningFilter {
        
        var semesters: [Int] = [0]
        
        init() {
            if let currentSemester = ApplicationManager.sharedInstance.user?.semester {
                self.semesters.append(currentSemester)
            }
        }
    }
    
    @IBOutlet weak var dataTableView: UITableView!
    
    var planningFilter: PlanningFilter!
    
    struct Data {
        var title: String!
        var data: [String]!
    }

    var tableViewData: [Data]!
    
    weak var delegate: PlanningFilterDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("filter", comment: "")
        
        var semesters = [String]()
        for i in 0...10 {
            semesters.append(String(format: "%@ %i", NSLocalizedString("Semester", comment: ""), i))
        }
        
        self.tableViewData = [
            Data(title: "Semesters", data: semesters)
        ]
        
        self.navigationController?.navigationBar.isHidden = false
        
    }

    @IBAction func doneButtonTouched(_ sender: Any) {
        delegate?.updateFilter(filter: self.planningFilter)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PlanningFilterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString(self.tableViewData[section].title, comment: "")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = UITableViewCell()
        
        cell.textLabel?.text = self.tableViewData[indexPath.section].data[indexPath.row]
        
        cell.tintColor = UIUtils.backgroundColor
        
        if self.planningFilter.semesters.contains(indexPath.row) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

extension PlanningFilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let index = self.planningFilter.semesters.index(of: indexPath.row) {
            self.planningFilter.semesters.remove(at: index)
        } else {
            self.planningFilter.semesters.append(indexPath.row)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
    
}
