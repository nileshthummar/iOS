//
//  HomeViewController.swift
//  HomeAwayDemo
//
//  Created by Nilesh on 6/2/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit
import Reachability

class HomeViewController: UIViewController {
    @IBOutlet var viewModel : HomeViewModel!
    @IBOutlet var tableView : UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    //Internet reachability check
    let reachability = Reachability()!
    var searchTask: DispatchWorkItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupSearchController()
        setupSearchBar()
        viewModel.fetchEvents(searchText: searchController.searchBar.text!) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    //check network reachability callback // we can move this in Utils package
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .none:
            print("Network not reachable")
            self.showToast(message: "Network not reachable")
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detailViewController" {
            if let indexPath = self.tableView.indexPathForSelectedRow {                
                let controller = segue.destination as! DetailViewController
                controller.viewModel.event = viewModel.eventForRowAtIndexPath(indexPath: indexPath)
            }
        }
    }
    fileprivate func setupSearchBar(){
        searchController.searchBar.tintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]        
    }
    fileprivate func setupSearchController(){
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Events"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    ///Show Toast // we can move this in Utils package
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 130, y: self.view.frame.size.height-100, width: 260, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
extension HomeViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        //check for text length > 3 if needed
        // Cancel previous task if any
        self.searchTask?.cancel()
        // Replace previous task with a new one
        let task = DispatchWorkItem { [weak self] in
            self?.sendSearchRequest()
        }
        self.searchTask = task        
        // Execute task in 0.5 seconds (if not cancelled !)
        //seconds update base on requirement
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: task)
        
    }
    func sendSearchRequest(){
        viewModel.fetchEvents(searchText: searchController.searchBar.text!) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
// MARK: - Table View
extension HomeViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section);
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HomeTableViewCell
        let event = viewModel.eventForRowAtIndexPath(indexPath: indexPath)
        cell.event = event
        return cell
    }
}

