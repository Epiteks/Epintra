//
//  HomeViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 24/01/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import RxSwift

class HomeViewController: LoadingDataViewController {

    @IBOutlet weak var alertTableView: UITableView!

    var tableFooterSave: UIView!

    /// Bag
    let bag = DisposeBag()

    /// Subscription to the user instance
    var notificationsSubscription: Disposable?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.alertTableView.rowHeight = UITableViewAutomaticDimension
        self.alertTableView.estimatedRowHeight = 60
        self.alertTableView.tableFooterView = UIView()
        self.alertTableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationCell")
    }

    override func awakeFromNib() {
        self.title = NSLocalizedString("Notifications", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        // Check data each time the view appears
        getNotificationsIfNeeded()
    }

    /// Get notifications if it is not available
    func getNotificationsIfNeeded() {

        let app = ApplicationManager.sharedInstance

        // Check if the current user data contains all needed fields.
        // Otherwise, download it.
        if ApplicationManager.sharedInstance.user?.value.history.value.count ?? 0 == 0 {

            // Add subscription to notifications
            self.notificationsSubscription = ApplicationManager.sharedInstance.user?.value.history.asObservable().subscribe(onNext: { [weak self] _ in
                self?.alertTableView.reloadData()
                self?.isFetching = false

                if let cnt = ApplicationManager.sharedInstance.user?.value.history.value.count, cnt == 0 {
                    self?.addNoDataView(info: "NoNotification")
                } else {
                    self?.removeNoDataView()
                }

                return
            })

            self.removeNoDataView()
            self.isFetching = true
            usersRequests.getHistory { _ in }
        }
        self.notificationsSubscription?.addDisposableTo(self.bag)
    }

}

extension HomeViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ApplicationManager.sharedInstance.user?.value.history.value.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! NotificationTableViewCell

        guard let history = ApplicationManager.sharedInstance.user?.value.history.value[indexPath.row] else {
            log.error("Error history Home")
            return cell
        }

        cell.userProfileImageView.image = UIImage(named: "userProfile")
        cell.userProfileImageView.cropToSquare()
        cell.userProfileImageView.toCircle()

        if let profileImageURL = history.userPicture, let url = URL(string: profileImageURL) {
            cell.userProfileImageView.downloadProfileImage(fromURL: url)
        }

        if let notificationTitle = history.title?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) {
            cell.notificationMessageLabel.text = notificationTitle
        }

        if let content = history.content?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) {
            cell.notificationMessageLabel.text = "\(cell.notificationMessageLabel.text!) - \(content)"
        }

        if let userName = history.userName, let date = history.date?.toAlertString() {
            cell.dateLabel.text = String(format: "%@ - %@", userName, date)
        }

        return cell
    }
}
