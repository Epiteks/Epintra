//
//  MarksViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 25/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ProjectMarksViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var marksTableView: UITableView!
    
    var marks: [Mark]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Marks", comment: "")
        
        self.marksTableView.estimatedRowHeight = 60
        self.marksTableView.rowHeight = UITableViewAutomaticDimension
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "markCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? StudentGradeTableViewCell
        
        if cell == nil {
            let nib = UINib(nibName: "StudentGradeTableViewCell", bundle:nil)
            tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? StudentGradeTableViewCell
        }
        
        let data = self.marks[indexPath.row]
        
        cell?.nameLabel.text = data.login
        cell?.gradeLabel.text = data.finalNote
        
        cell?.selectionStyle = .none
        
        return cell!
    }
    
}
