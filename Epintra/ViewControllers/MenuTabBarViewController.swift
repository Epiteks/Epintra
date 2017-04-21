//
//  MenuTabBarViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 21/04/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit

class MenuTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {

        guard let credentials = KeychainUtil.getCredentials(), credentials.token != nil else {
            // Should go back to login view controller
            let vc = UIStoryboard(name: "ConnexionStoryboard", bundle: nil).instantiateInitialViewController()!
            self.present(vc, animated: true, completion: nil)
            return
        }
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

}
