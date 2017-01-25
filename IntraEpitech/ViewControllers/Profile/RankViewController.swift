//
//  RankViewController.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 29/12/2016.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit
import RealmSwift

class RankViewController: LoadingDataViewController {
    
    @IBOutlet weak var studentsTableView: UITableView!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    var rankFilter: FilterRankViewController.RankFilter! {
        willSet {
            self.tableViewContentWasUpdated = true
        }
    }
    
    var tableViewContentWasUpdated: Bool = false
    
    var searchController: UISearchController!
    
    var students: Results<StudentInfo>? {
        willSet {
            self.filteredStudents = newValue
        }
    }
    var filteredStudents: Results<StudentInfo>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Ranking", comment: "")
        
        self.studentsTableView.register(UINib(nibName: "StudentTableViewCell", bundle: nil), forCellReuseIdentifier: "studentInfoCell")
        self.studentsTableView.estimatedRowHeight = 60
        self.studentsTableView.rowHeight = UITableViewAutomaticDimension
        
        self.configureSearchController()
        
        self.rightBarButtonItem.tintColor = UIUtils.backgroundColor
        
        self.rankFilter = FilterRankViewController.RankFilter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDataIfNeeded()
    }
    
    func getDataIfNeeded() {
        
        let promotion = String(format: "tek%i", self.rankFilter.promotion)
        
        let realmStudentInfo = RealmStudentInfo()
        
        guard let epirankInformation = realmStudentInfo.epirankInformation(forPromo: promotion) else {
            fetchNewData()
            return
        }
        
        if epirankInformation.needsNewerData() {
            fetchNewData()
        } else {
            self.students = realmStudentInfo.students(byPromotion: promotion, andCities: self.rankFilter.cities)
        }
        
        self.studentsTableView.reloadData()
    }
    
    func fetchNewData() {
        self.isFetching = true
        let promotion = String(format: "tek%i", self.rankFilter.promotion)
        usersRequests.download(students: promotion) { result in
            if self.isViewLoaded && self.view.window != nil {
                switch result {
                case .success(let students):
                    self.students = students
                    self.studentsTableView.reloadData()
                case .failure(let err):
                    self.showAlert(withTitle: "error", andMessage: err.message)
                }
                self.isFetching = false
            } else {
                log.warning("Rank view controller is not on top")
            }
        }
    }
    
    @IBAction func filterSearchSegue(_ sender: Any) {
        self.performSegue(withIdentifier: "filterSearchSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterSearchSegue", let navController = segue.destination as? UINavigationController, let vc = navController.viewControllers.first as? FilterRankViewController {
            vc.rankFilter = self.rankFilter
            vc.delegate = self
        }
    }
    
}

extension RankViewController: UpdateRankFilterDelegate {
    func updateRank(rank: FilterRankViewController.RankFilter) {
        self.rankFilter = rank
    }
}

extension RankViewController: UISearchResultsUpdating {
    
    func configureSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.tintColor = UIUtils.backgroundColor
        self.searchController.searchBar.sizeToFit()
        self.studentsTableView.tableHeaderView = searchController.searchBar
    }
    
    /// Update students table view data
    ///
    /// - Parameter data: user research
    func filterStudentsContent(for data: String) {
        if data.characters.count == 0 {
            self.filteredStudents = self.students
        } else {
            let query = NSPredicate(format: "login CONTAINS[c] %@ or title CONTAINS[c] %@", data, data)
            self.filteredStudents = self.students?.filter(query)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let data = searchController.searchBar.text {
            filterStudentsContent(for: data)
        } else {
            self.filteredStudents = self.students
        }
        self.studentsTableView.reloadData()
    }
    
}

extension RankViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Register nib for each tableview, because of search controller
        tableView.register(UINib(nibName: "StudentTableViewCell", bundle: nil), forCellReuseIdentifier: "studentInfoCell")
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredStudents?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentInfoCell") as? StudentTableViewCell
        
        if (self.filteredStudents?.count)! > indexPath.row, let student = self.filteredStudents?[indexPath.row] {
            cell?.titleLabel.text = student.title
            cell?.gpaLabel.text = String(describing: student.bachelor.value!)
            cell?.informationsLabel.text = String(format: "%@ - %@", student.city!, student.login!)
            //cell?.accessoryType = .disclosureIndicator
            
            if let position = self.students?.index(of: student) {
                cell?.positionLabel?.text = String(position + 1)
            }
        }
        return cell ?? UITableViewCell()
    }
    
}

extension RankViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
