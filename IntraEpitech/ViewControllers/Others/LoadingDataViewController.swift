//
//  LoadingDataViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 23/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit


/// Used for viewcontrollers that need to fetch data to show
class LoadingDataViewController: UIViewController {
    
    /// Know if the view is currently fetching data
    var isFetching: Bool = false {
        willSet {
            newValue == true ? addLoadingScreen() : removeLoadingScreen()
        }
    }
    
    var willLoadNextView: Bool = false
    
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
    
    func addNoDataView() {
        let noData = NoDataView(info: NSLocalizedString("NoNotification", comment: ""))
        noData.frame = self.view.frame
        self.view.addSubview(noData)
    }
    
    func removeNoDataView() {
        for sub in self.view.subviews {
            if sub is NoDataView {
                sub.removeFromSuperview()
                break
            }
        }
    }

}