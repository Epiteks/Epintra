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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventsTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "eventCell")
        self.eventsTableView.estimatedRowHeight = 50
        self.eventsTableView.rowHeight = UITableViewAutomaticDimension
        
        self.todayButtonItem.title = NSLocalizedString("Today", comment: "")
        self.filterButtonItem.title = NSLocalizedString("filter", comment: "")
        
        self.setCalendar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
         self.reloadEventsData()
    }
    
    override func awakeFromNib() {
        self.title = NSLocalizedString("Planning", comment: "")
    }
    
    func reloadEventsData() {
        
        self.addLoadingScreen(for: self.eventsTableView)
        
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
            self.removeLoadingScreen(for: self.eventsTableView)
        }
    }
    
    func setDataToDisplay() {
        
        let calendar = Calendar.current
        let selectedDate = self.calendarView.selectedDate
        
        // Filter events to get only those this day
        self.currentDayEvents = self.currentWeekEvents?.filter {
            
            if let startTime = $0.startTime {
                
                let comp1 = calendar.component(.day, from: startTime)
                let comp2 = calendar.component(.day, from: selectedDate)
            
                return comp1 == comp2
            }
            return false
        }
        self.eventsTableView.reloadData()
    }

    @IBAction func todayButtonItemSelected(_ sender: Any) {
        self.calendarView.select(Date(), scrollToDate: true)
        self.calendarView.select(Date())
    }
    
    @IBAction func filterButtonItemSelected(_ sender: Any) {
    }
}

extension PlanningViewController: FSCalendarDataSource, FSCalendarDelegate {
 
    func setCalendar() {
        
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
        
        return cell
    }
    
}
