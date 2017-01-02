//
//  SchoolViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class SchoolViewController: UIViewController {
    
    @IBOutlet weak var menuControl: UISegmentedControl!
    @IBOutlet weak var modulesContainer: UIView!
    @IBOutlet weak var projectsContainer: UIView!
    @IBOutlet weak var marksContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.menuControl.setTitle(NSLocalizedString("Modules", comment: ""), forSegmentAt: 0)
        self.menuControl.setTitle(NSLocalizedString("Projects", comment: ""), forSegmentAt: 1)
        self.menuControl.setTitle(NSLocalizedString("Marks", comment: ""), forSegmentAt: 2)
        
        showSpecificView(atIndex: 0)
        
        self.navigationItem.title = ""
    }
    
    override func awakeFromNib() {
        self.title = NSLocalizedString("School", comment: "")
    }

    @IBAction func selectedMenuItem(_ sender: UISegmentedControl) {
       showSpecificView(atIndex: sender.selectedSegmentIndex)
    }
    
    func showSpecificView(atIndex index: Int) {
     
        self.modulesContainer.isHidden = true
        self.projectsContainer.isHidden = true
        self.marksContainer.isHidden = true
        
        switch index {
        case 0:
            self.modulesContainer.isHidden = false
        case 1:
            self.projectsContainer.isHidden = false
        default:
            self.marksContainer.isHidden = false
        }
    }
}
