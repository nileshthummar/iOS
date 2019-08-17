//
//  ViewController.swift
//  GMDemo
//
//  Created by Nilesh on 8/8/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet  var tableView: UITableView!
    private let dataSource = CommitDataSource()
    lazy var viewModel : HomeViewModel = {
        let viewModel = HomeViewModel(dataSource: dataSource)
        return viewModel
    }()
    //Internet reachability check
    private let reachability = Reachability()!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Commits"
        self.tableView.dataSource = self.dataSource
        // Do any additional setup after loading the view.
        self.dataSource.data.addAndNotify(observer: self) { [weak self] _ in
            self?.tableView.reloadData()
        }
        // add error handling example
        self.viewModel.onErrorHandling = { [weak self] error in
            // display error ?
            self?.showToast(title: "An error occured", message: "Oops, something went wrong!")
        }
        self.viewModel.fetchData {}
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: ReachabilityChangedNotification, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    //check network reachability callback // we can move this in Utils package
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.currentReachabilityStatus {
        case .reachableViaWiFi:
            print("Reachable via WiFi")
        case .reachableViaWWAN:
            print("Reachable via Cellular")
        case .notReachable:
            print("Network not reachable")
            self.showToast(title: "Connection", message: "Network not reachable")      
        }
    }
    ///Show Toast // we can move this in Utils package
    func showToast(title: String , message : String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }

}

