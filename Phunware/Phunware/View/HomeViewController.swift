//
//  HomeViewController.swift
//  Phunware
//
//  Created by Nilesh on 6/16/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private let dataSource = EventDataSource()
    private var selectedPerson : Person?
    private var selectedImage : UIImage?
    lazy var viewModel : HomeViewModel = {
        let viewModel = HomeViewModel(dataSource: dataSource)
        return viewModel
    }()    
    private var estimateWidth = 375.0 /// Cell estimateWidth, will be updated as per screen size
    private var cellMarginSize = 0.0 /// no margin as per wireframe
    private var selectedFrame : CGRect? // for custom animation start animation from cell frame
    private var customInteractor : CustomInteractor? // For custom animation    
    //Internet reachability check
    private let reachability = Reachability()!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "PHUN APP"
        self.setupGridView()
        self.navigationController?.delegate = self
        
        self.collectionView.dataSource = self.dataSource
        self.collectionView.delegate = self;
        // Do any additional setup after loading the view.
        self.dataSource.data.addAndNotify(observer: self) { [weak self] _ in
            self?.collectionView.reloadData()
        }
        // add error handling example
        self.viewModel.onErrorHandling = { [weak self] error in
            // display error ?
            self?.showToast(title: "An error occured", message: "Oops, something went wrong!")            
        }
        self.viewModel.fetchData {
            
        }
    
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupGridView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeDetailsViewController" {
            let controller = segue.destination as! HomeDetailsViewController
            controller.person = self.selectedPerson
        }
    }
    ///CollectionView setup
    func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    ///Show Toast // we can move this in Utils package
    func showToast(title: String , message : String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
    
}
//MARK UINavigationControllerDelegate
extension HomeViewController: UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let ci = customInteractor else { return nil }
        return ci.transitionInProgress ? customInteractor : nil
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let frame = self.selectedFrame else { return nil }
        
        switch operation {
        case .push:
            self.customInteractor = CustomInteractor(attachTo: toVC)
            
            return CustomAnimator(duration: TimeInterval(UINavigationController.hideShowBarDuration), isPresenting: true, originFrame: frame, image: self.selectedImage ?? UIImage())
        default:
            return CustomAnimator(duration: TimeInterval(UINavigationController.hideShowBarDuration), isPresenting: false, originFrame: frame, image: self.selectedImage ?? UIImage())
        }
    }
}
///MARK UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedPerson = dataSource.data.value[indexPath.row]
        let cell =  collectionView .cellForItem(at: indexPath) as? HomeViewCell
        self.selectedImage =  cell?.imgView.image
        
        let theAttributes:UICollectionViewLayoutAttributes! = collectionView.layoutAttributesForItem(at: indexPath)
        selectedFrame = collectionView.convert(theAttributes.frame, to: collectionView.superview)
        self.performSegue(withIdentifier: "homeDetailsViewController", sender: self)
    }
}
///MARK UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width/2)
    }
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        return width
    }
}
