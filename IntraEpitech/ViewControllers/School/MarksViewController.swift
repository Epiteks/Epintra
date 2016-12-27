//
//  AllMarksViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 27/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class MarksViewController: SchoolDataViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var marksTableView: UITableView!
    var marks: [Mark]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.marksTableView.rowHeight = UITableViewAutomaticDimension
        self.marksTableView.estimatedRowHeight = 60
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ApplicationManager.sharedInstance.user?.marks == nil {
            getMarks()
        }
    }
    
    func getMarks() {
        self.isFetching = true
        usersRequests.allMarks { (result) in
            switch result {
            case .success(let data):
                self.marks = data
                ApplicationManager.sharedInstance.user?.marks = data
                self.marksTableView.reloadData()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.marks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "studentRegisteredCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? StudentGradeTableViewCell
        
        if cell == nil {
            let nib = UINib(nibName: "StudentGradeTableViewCell", bundle:nil)
            tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? StudentGradeTableViewCell
        }
        
        if let data = self.marks?[indexPath.row] {
            cell?.nameLabel.text = data.title
            cell?.gradeLabel.text = data.finalNote
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
