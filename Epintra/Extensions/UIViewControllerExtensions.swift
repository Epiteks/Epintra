//
//  UIViewControllerExtensions.swift
//  Epintra
//
//  Created by Maxime Junger on 19/04/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    /// Add ActivityIndicator on center of the view
    func addActivityIndicator() {

        self.removeActivityIndicator()

        let indicator = UIActivityIndicatorView()

        indicator.center = self.view.center
        indicator.activityIndicatorViewStyle = .whiteLarge

        indicator.color = .white
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

    /// Show an UIAlertController with default title Error.
    ///
    /// - Parameter message: message to show
    func showError(withMessage message: String?) {

        let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default)
        alert.addAction(action)
        alert.view.tintColor = UIUtils.backgroundColor

        self.present(alert, animated: true)
        
    }
    
}
