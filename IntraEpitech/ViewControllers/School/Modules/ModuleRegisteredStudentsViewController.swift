//
//  ModuleRegisteredStudentsViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 24/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ModuleRegisteredStudentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var studentsTableView: UITableView!
    
    var students: [RegisteredStudent]?
    
    var currentStudentIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Grades", comment: "")
        
        self.studentsTableView.register(UINib(nibName: "StudentGradeTableViewCell", bundle: nil), forCellReuseIdentifier: "studentRegisteredCell")
        self.studentsTableView.estimatedRowHeight = 60
        self.studentsTableView.rowHeight = UITableViewAutomaticDimension
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        for (index, student) in self.students!.enumerated() {
           
            if student.login == ApplicationManager.sharedInstance.user?.login {
                self.studentsTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: UITableViewScrollPosition.top, animated: true)
            }
            
        }

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "studentRegisteredCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? StudentGradeTableViewCell
        
        if let student = students?[indexPath.row] {
            cell?.nameLabel.text = student.login
            cell?.gradeLabel.text = student.grade
          
            if student.login == ApplicationManager.sharedInstance.user?.login {
                cell?.nameLabel.textColor = .red
                cell?.gradeLabel.textColor = .red
            } else {
                cell?.nameLabel.textColor = .black
                cell?.gradeLabel.textColor = .black

            }
            
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
