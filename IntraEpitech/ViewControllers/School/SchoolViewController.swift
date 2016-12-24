//
//  SchoolViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 22/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class SchoolViewController: UIViewController {
    
    @IBOutlet weak var menuControl: UISegmentedControl!
    @IBOutlet weak var modulesContainer: UIView!
    @IBOutlet weak var projectsContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.menuControl.setTitle(NSLocalizedString("Modules", comment: ""), forSegmentAt: 0)
        self.menuControl.setTitle(NSLocalizedString("Projects", comment: ""), forSegmentAt: 1)
        self.menuControl.setTitle(NSLocalizedString("Marks", comment: ""), forSegmentAt: 2)
        
        showSpecificView(atIndex: 0)
        
        self.navigationItem.title = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
    //    self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.title = NSLocalizedString("School", comment: "")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func selectedMenuItem(_ sender: UISegmentedControl) {
       showSpecificView(atIndex: sender.selectedSegmentIndex)
    }
    
    func showSpecificView(atIndex index: Int) {
     
        self.modulesContainer.isHidden = true
        self.projectsContainer.isHidden = true
        
        switch index {
        case 0:
            self.modulesContainer.isHidden = false
        default:
            self.projectsContainer.isHidden = false
        }
        
    }
}
