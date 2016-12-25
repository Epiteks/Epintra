//
//  SchoolDataViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 23/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class SchoolDataViewController: UIViewController {
    
    /// Know if the view is currently fetching data
    var isFetching: Bool = false {
        willSet {
            newValue == true ? addLoadingScreen() : removeLoadingScreen()
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
    
    /// Add LoadingView screen
    func addLoadingScreen() {
        
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
    
    /// Remove LoadingView screen
    func removeLoadingScreen() {
        
        for sub in self.view.subviews {
            if sub.restorationIdentifier == "loadingView" {
                sub.removeFromSuperview()
                break
            }
        }
    }
    
    /// Add ActivityIndicator on center of the view
    func addActivityIndicator() {
        
        let indicator = UIActivityIndicatorView()
        
        indicator.center = self.view.center
        indicator.activityIndicatorViewStyle = .gray
        
        indicator.color = .black
        indicator.startAnimating()
        
        self.view.addSubview(indicator)
    }

    /// Remove ActivityIndicator
    func removeActivityIndicator() {
        for sub in self.view.subviews {
            if sub is UIActivityIndicatorView {
                sub.removeFromSuperview()
                break
            }
        }
    }

}
