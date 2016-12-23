//
//  SchoolDataViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 23/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class SchoolDataViewController: UIViewController {

    var isFetching: Bool = false {
        willSet {
            newValue == true ? setLoadingScreen() : removeLoadingScreen()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func setLoadingScreen() {
        
        for sub in self.view.subviews {
            if sub.restorationIdentifier == "loadingView" {
                log.warning("Loading view already present. Not adding it.")
                return
            }
        }
        
        let loadingView = LoadingView(frame: self.view.frame)
        
        loadingView.restorationIdentifier = "loadingView"
        
        self.view.addSubview(loadingView)
    }
    
    func removeLoadingScreen() {
        
        for sub in self.view.subviews {
            if sub.restorationIdentifier == "loadingView" {
                sub.removeFromSuperview()
                break
            }
        }
    }

}
