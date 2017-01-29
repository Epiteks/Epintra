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
    func addLoadingScreen(for otherView: UIView? = nil) {
        
        let viewToSearchOn: UIView = otherView ?? self.view
        
        for sub in viewToSearchOn.subviews {
            if sub.restorationIdentifier == "loadingView" {
                log.warning("Loading view already present. Not adding it.")
                return
            }
        }
        
        let loadingView = LoadingView(frame: viewToSearchOn.frame)
        
        loadingView.restorationIdentifier = "loadingView"
        
        DispatchQueue.main.async {
            viewToSearchOn.addSubview(loadingView)
        }
    }
    
    /// Remove LoadingView screen
    func removeLoadingScreen(for otherView: UIView? = nil) {
        
        let viewToSearchOn: UIView = otherView ?? self.view
        
        for sub in viewToSearchOn.subviews {
            if sub.restorationIdentifier == "loadingView" {
                DispatchQueue.main.async {
                    sub.removeFromSuperview()
                }
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
        DispatchQueue.main.async {
            self.view.addSubview(indicator)
        }
    }
    
    /// Remove ActivityIndicator
    func removeActivityIndicator() {
        for sub in self.view.subviews {
            if sub is UIActivityIndicatorView {
                DispatchQueue.main.async {
                    sub.removeFromSuperview()
                }
                break
            }
        }
    }
    
    /// Add NoData View
    func addNoDataView(info: String) {
        let noData = NoDataView(info: NSLocalizedString(info, comment: ""))
        noData.frame = self.view.frame
        DispatchQueue.main.async {
            self.view.addSubview(noData)
        }
    }
    
    /// Remove NoData View
    func removeNoDataView() {
        for sub in self.view.subviews {
            if sub is NoDataView {
                DispatchQueue.main.async {
                    sub.removeFromSuperview()
                }
                break
            }
        }
    }
    
    func showAlert(withTitle title: String, andMessage message: String? = nil) {
        
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""), message: message ?? "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { _ in
            
        })
        self.present(alert, animated: true)
        alert.view.tintColor = UIUtils.backgroundColor
        
    }
}
