//
//  ModulesViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 22/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

class ModulesViewController: LoadingDataViewController {

    @IBOutlet weak var modulesTableView: UITableView!

    var modules: [Module]?

    override func viewDidLoad() {
        self.modulesTableView.rowHeight = UITableViewAutomaticDimension
        self.modulesTableView.estimatedRowHeight = 60
        self.modulesTableView.register(UINib(nibName: "ModuleTableViewCell", bundle: nil), forCellReuseIdentifier: "moduleCell")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moduleDetailsSegue" {
            if let vc = segue.destination as? ModuleDetailsViewController, let module = sender as? Module {
                vc.module = module
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if ApplicationManager.sharedInstance.user?.value.modules == nil {
            getModules()
        }
    }

    func getModules() {

        self.isFetching = true

        modulesRequests.usersModules { [weak self] result in
            switch result {
            case .success(let data):
                log.info("User modules fetched")
                self?.modules = data
                ApplicationManager.sharedInstance.user?.value.modules = data
                self?.modulesTableView.reloadData()
                self?.removeNoDataView()
                break
            case .failure(let error):
                if let tmpSelf = self, let message = error.message {
                    ErrorViewer.errorPresent(tmpSelf, mess: message) { }
                }
                if self?.modules == nil || self?.modules?.count == 0 {
                    self?.addNoDataView(info: "Empty")
                }
                break
            }
            self?.isFetching = false
        }
    }
}

extension ModulesViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modules?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "moduleCell"

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ModuleTableViewCell

        if let data = modules?[indexPath.row] {
            cell?.titleLabel.text = data.title
            cell?.creditsAvailableLabel.text = NSLocalizedString("AvailableCredits", comment: "") + data.credits!
            if (data.grade != nil) {
                cell?.gradeLabel.text = data.grade!
            }
            cell?.accessoryType = .disclosureIndicator
        }
        return cell ?? UITableViewCell()
    }

}

extension ModulesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.willLoadNextView == false {
            self.willLoadNextView = true
            self.addActivityIndicator()
            if let module = self.modules?[indexPath.row] {
                module.getDetails { [weak self] _ in
                    self?.performSegue(withIdentifier: "moduleDetailsSegue", sender: module)
                    self?.removeActivityIndicator()
                    self?.willLoadNextView = false
                }
            }
        }
    }
    
}
