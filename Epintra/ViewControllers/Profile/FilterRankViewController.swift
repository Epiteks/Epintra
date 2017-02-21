//
//  FilterRankViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 30/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class FilterRankViewController: UIViewController {
    
    struct RankFilter {
        var promotion: Int
        var cities = ["All"]
        
        init() {
            if let studentYear = ApplicationManager.sharedInstance.user?.studentyear {
                self.promotion = studentYear < 4 ? studentYear : 3 // Tek3 if user is tek[more]
            } else {
                self.promotion = 3
            }
        }
    }
    
    @IBOutlet weak var dataTableView: UITableView!
    
    var rankFilter: RankFilter!
    
    struct Data {
        var title: String!
        var data: [String]!
    }
    
    var tableViewData = [
        Data(title: "promotion", data: ["tek1", "tek2", "tek3"]),
        Data(title: "city", data: ["All", "BDX", "LIL", "LYN", "MAR", "MPL", "NAN", "NCE", "NCY", "PAR", "REN", "STG", "TLS"])
    ]
    
    weak var delegate: UpdateRankFilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("filter", comment: "")
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func doneButtonTouched(_ sender: Any) {
        delegate?.updateRank(rank: self.rankFilter)
        self.dismiss(animated: true, completion: nil)
    }

}

extension FilterRankViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        let data = self.tableViewData[indexPath.section].data[indexPath.row]
        
        cell.tintColor = UIUtils.backgroundColor
        cell.textLabel?.text = NSLocalizedString(data, comment: "")
        
        if (indexPath.section == 0 && self.rankFilter.promotion == (indexPath.row + 1))
            || (indexPath.section == 1 && self.rankFilter.cities.contains(data)) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }

}

extension FilterRankViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            self.rankFilter.promotion = indexPath.row + 1
        } else {
            
            switch indexPath.row {
            case 0: // ALL cities
                self.rankFilter.cities.removeAll()
                self.rankFilter.cities.append(self.tableViewData[1].data[0])
            default:
                
                if self.rankFilter.cities.contains(self.tableViewData[1].data[0]) {
                    self.rankFilter.cities.removeAll()
                }
                
                let cellData = self.tableViewData[1].data[indexPath.row]
                
                if let index = self.rankFilter.cities.index(of: cellData) {
                    self.rankFilter.cities.remove(at: index)
                } else {
                    self.rankFilter.cities.append(cellData)
                }
            }
        }
        tableView.reloadSections([indexPath.section], with: UITableViewRowAnimation.automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
