//
//  PlanningViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 09/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit
import FSCalendar

class PlanningViewController: LoadingDataViewController {

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var eventsTableViewTopLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var todayButtonItem: UIBarButtonItem!
    @IBOutlet weak var filterButtonItem: UIBarButtonItem!

    var currentWeekEvents: [Planning]? = nil
    var currentDayEvents: [Planning]? = nil
    
    var planningFilter = PlanningFilterViewController.PlanningFilter()
    
    var appointmentDetailsData: AppointmentEvent? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventsTableView.tableFooterView = UIView()
        self.eventsTableView.separatorInset = .zero
        self.eventsTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "eventCell")
        self.eventsTableView.estimatedRowHeight = 50
        self.eventsTableView.rowHeight = UITableViewAutomaticDimension
        
        self.setCalendar()
        self.reloadEventsData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "planningFilterSegue" {
            if let nav = segue.destination as? UINavigationController, let vc = nav.viewControllers.first as? PlanningFilterViewController {
                vc.delegate = self
                vc.planningFilter = self.planningFilter
            }
        } else if segue.identifier == "appointmentDetailsSegue" {
            if let vc = segue.destination as? AppointmentDetailsViewController {
                if let data = self.appointmentDetailsData {
                    vc.appointment = data
                }
            }
        }
    }
    
    override func awakeFromNib() {
        self.title = NSLocalizedString("Planning", comment: "")
        
        self.todayButtonItem.title = NSLocalizedString("Today", comment: "")
        self.todayButtonItem.image = nil
        self.filterButtonItem.title = NSLocalizedString("filter", comment: "")
        self.filterButtonItem.image = nil
    }
    
    func reloadEventsData() {
        
        self.addActivityIndicator()
        
        let firstDayShown = self.calendarView.currentPage
        let lastDayShown = firstDayShown.endOfWeekDate()
        
        planningRequests.getPlanning(for: firstDayShown, end: lastDayShown) { result in
            switch result {
            case .success(let events):
                self.currentWeekEvents = events
                self.setDataToDisplay()
            case .failure(let error):
                // TODO Handle error
                break
            }
            self.removeActivityIndicator()
        }
    }
    
    func setDataToDisplay() {
        
        let calendar = Calendar.current
        let selectedDate = self.calendarView.selectedDate
        
        // Filter events to get only those this day
        self.currentDayEvents = self.currentWeekEvents?.filter {
            if let startTime = $0.startTime {

                if let semester = $0.semester, let index = self.planningFilter.semesters.index(of: semester), index >= 0 {
                    return calendar.component(.day, from: startTime) == calendar.component(.day, from: selectedDate)
                } else {
                    return false
                }
            }
            return false
        }
        self.eventsTableView.reloadData()
    }
    
    @IBAction func todayButtonItemSelected(_ sender: Any) {
        self.calendarView.select(Date(), scrollToDate: true)
        self.calendarView.select(Date())
    }
    
    @IBAction func filterButtonSelected(_ sender: Any) {
        self.performSegue(withIdentifier: "planningFilterSegue", sender: self)
    }
}

extension PlanningViewController: FSCalendarDataSource, FSCalendarDelegate {
 
    func setCalendar() {
        
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        
        self.calendarView.scope = .week
        self.calendarView.firstWeekday = 2
        
        self.calendarView.allowsMultipleSelection = false
        
        self.calendarView.today = Date()
        self.calendarView.select(Date())
        self.calendarView.setCurrentPage(Date(), animated: false)
    
        self.calendarView.appearance.todayColor = .clear
        self.calendarView.appearance.todaySelectionColor = UIUtils.backgroundColor
        self.calendarView.appearance.selectionColor = .black
        self.calendarView.appearance.titleDefaultColor = .black
        self.calendarView.appearance.titleWeekendColor = .black
        self.calendarView.appearance.weekdayTextColor = .black
        self.calendarView.appearance.headerTitleColor = .black
        self.calendarView.appearance.titleTodayColor = UIUtils.backgroundColor
        
        self.calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        
        self.calendarView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.eventsTableViewTopLayoutConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
        self.calendarView.select(calendar.currentPage)
        self.calendarView.reloadData()
        
        self.reloadEventsData()
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        self.setDataToDisplay()
    }

}

extension PlanningViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentDayEvents?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventTableViewCell
        
        cell.setView(with: self.currentDayEvents![indexPath.row])
        
        if cell.accessoryType != .disclosureIndicator {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.statusImageSelected(_:)))
            tapGesture.numberOfTapsRequired = 1
            cell.statusImageView.isUserInteractionEnabled = true
            cell.statusImageView.addGestureRecognizer(tapGesture)
            cell.statusImageView.tag = indexPath.row
        }
        
        return cell
    }
    
    func statusImageSelected(_ sender: UIGestureRecognizer) {
    
            if let statusImageView = sender.view as? UIImageView, let data = self.currentDayEvents?[statusImageView.tag] {
                if data.canEnterToken {
                    // Enter Token Alert View
                    self.enterTokenAlertView(planningEvent: data)
                } else if data.canRegister {
                    // Register student
                    self.addActivityIndicator()
                    planningRequests.register(toEvent: data, completion: { result in
                        
                        self.removeActivityIndicator()
                        switch result {
                        case .success(_):
                            if let eventIndex = self.currentDayEvents?.index(where: { $0 == data }) {
                                    self.eventsTableView.reloadRows(at: [IndexPath(row: eventIndex, section: 0)], with: .automatic)
                                }
                            break
                        case .failure(let err):
                            if let message = err.message {
                                self.showAlert(withTitle: "error", andMessage: message)
                            }
                            break
                        }
                    })
                    
                } else if data.canUnregister {
                    // Unregister Student
                    self.addActivityIndicator()
                    planningRequests.unregister(fromEvent: data, completion: { result in
                        self.removeActivityIndicator()
                        switch result {
                        case .success(_):
                            if let eventIndex = self.currentDayEvents?.index(where: { $0 == data }) {
                                self.eventsTableView.reloadRows(at: [IndexPath(row: eventIndex, section: 0)], with: .automatic)
                            }
                            break
                        case .failure(let err):
                            if let message = err.message {
                                self.showAlert(withTitle: "error", andMessage: message)
                            }
                            break
                        }
                    })
                }
            }
            
        }
    
    func enterTokenAlertView(planningEvent data: Planning) {
        
        let alert = UIAlertController(title: NSLocalizedString("EnterToken", comment: ""), message: "", preferredStyle: .alert)
        var tokenTextField: UITextField!
        
        alert.addTextField { textField in
            textField.placeholder = NSLocalizedString("Token", comment: "")
            tokenTextField = textField
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { _ in
            self.addActivityIndicator()
            if let token = tokenTextField.text, token.characters.count > 0 {
                planningRequests.enter(token: token, for: data, completion: { result in
                    self.removeActivityIndicator()
                    switch result {
                    case .success(_):
                        if let eventIndex = self.currentDayEvents?.index(where: { $0 == data }) {
                            self.eventsTableView.reloadRows(at: [IndexPath(row: eventIndex, section: 0)], with: .automatic)
                        }
                        break
                    case .failure(let err):
                        if let message = err.message {
                            self.showAlert(withTitle: "error", andMessage: message)
                        }
                        break
                    }
                })
            }
        }))
        self.present(alert, animated: true)
    }
}

extension PlanningViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let data = self.currentDayEvents?[indexPath.row] {
            planningRequests.getSlots(forEvent: data) { result in
                switch result {
                case .success(let appointment):
                    self.appointmentDetailsData = appointment
                    self.performSegue(withIdentifier: "appointmentDetailsSegue", sender: self)
                case .failure(let err):
                    print(err)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension PlanningViewController: PlanningFilterDelegate {
    
    func updateFilter(filter: PlanningFilterViewController.PlanningFilter) {
        self.planningFilter = filter
    }
    
}
