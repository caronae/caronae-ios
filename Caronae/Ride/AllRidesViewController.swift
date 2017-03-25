import UIKit

class AllRidesViewController: RideListController, SearchRideDelegate {
    let userDefaults = UserDefaults.standard
    var searchParams: [String: Any] = [:]
    var filterParams: [String: Any] = [:]
    fileprivate var nextPage = 2
    fileprivate var lastUpdate = Date.distantPast

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.view.backgroundColor = UIColor.white
        navigationItem.titleView = UIImageView(image: UIImage(named: "NavigationBarLogo"))
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.reloadRidesIfNecessary), name: .UIApplicationWillEnterForeground, object: nil)
        
        // Setting up infinite scroll
        tableView.infiniteScrollTriggerOffset = 500
        
        tableView.addInfiniteScroll { tableView in
            self.loadAllRides(page: self.nextPage) {
                tableView.finishInfiniteScroll()
            }
        }
        
        self.filterIsEnabled = userDefaults.bool(forKey: CaronaePreferenceFilterIsEnabledKey)
        
        if self.filterIsEnabled {
            enableFilterRides()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadRidesIfNecessary()
    }
    
    func refreshTable() {
        loadAllRides()
    }
    
    
    // MARK: Table methods
    
    lazy var tableFooter: UIView = {
        let tableFooter = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        tableFooter.text = "Quer encontrar mais caronas? Use a pesquisa! 🔍"
        tableFooter.numberOfLines = 0
        tableFooter.backgroundColor = .white
        tableFooter.font = .systemFont(ofSize: 10)
        tableFooter.textColor = .lightGray
        tableFooter.textAlignment = .center
        return tableFooter
    }()
    
    
    // MARK: Rides methods
    
    func loadAllRides(page: Int = 1, _ completionHandler: ((Void) -> Void)? = nil) {
        if tableView.backgroundView != nil {
            tableView.backgroundView = loadingLabel
        }
        
        RideService.instance.getAllRides(page: page, success: { rides in
            
            if page == 1 {
                self.nextPage = 2
                self.lastUpdate = Date()
                self.rides = rides
                
                if rides.count > 0 {
                    self.tableView.tableFooterView = self.tableFooter
                } else {
                    self.tableView.tableFooterView = nil
                }
                
                self.tableView.reloadData()
            } else {
                guard rides.count > 0 else {
                    completionHandler?()
                    return
                }
                
                self.nextPage += 1
                let ridesCount = self.filteredRides.count
                
                // Update rides
                var allRides = self.rides as! [Ride]
                allRides.append(contentsOf: rides)
                self.rides = allRides
                
                // Create new index paths
                let (start, end) = (ridesCount, self.filteredRides.count)
                let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }
                
                // Update table view
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: indexPaths, with: .automatic)
                self.tableView.endUpdates()
            }
            
            self.refreshControl.endRefreshing()
            completionHandler?()
        }, error: { error in
            self.refreshControl.endRefreshing()
            completionHandler?()
            self.loadingFailedWithError(error)
        })
    }
    
    func reloadRidesIfNecessary() {
        if lastUpdate.timeIntervalSinceNow.isLess(than: -5*60) {
            loadAllRides()
        }
    }
    
    func enableFilterRides() {
        guard let center = userDefaults.string(forKey: CaronaePreferenceLastFilteredCenterKey),
            let neighborhoods = userDefaults.array(forKey: CaronaePreferenceLastFilteredNeighborhoodsKey) as? [String] else {
                return
        }
        
        self.filterIsEnabled = true
        filterParams = ["center": center,
                        "neighborhoods": neighborhoods]
        
        let label = center + ", " + neighborhoods.joined(separator: ", ")
        filterLabel.text = label
        
        loadAllRides()
        // workaround to not cover cell after enabling filter
        tableView.setContentOffset(CGPoint.init(x: 0, y: -500), animated: true)
    }
    
    override func didTapClearFilterButton(_ sender: UIButton!) {
        super.didTapClearFilterButton(sender);
        
        userDefaults.set(false, forKey: CaronaePreferenceFilterIsEnabledKey)
        self.filterParams = [:]
        loadAllRides()
    }
    
    
    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchRide" {
            if let searchNavController = segue.destination as? UINavigationController {
                let searchVC = searchNavController.viewControllers.first as! SearchRideViewController
                searchVC.previouslySelectedSegmentIndex = self.directionControl.selectedSegmentIndex
                searchVC.delegate = self
            }
        } else if segue.identifier == "ViewSearchResults" {
            if let searchViewController = segue.destination as? SearchResultsViewController {
                searchViewController.searchedForRide(withCenter: searchParams["center"] as! String!,
                                                     andNeighborhoods: searchParams["neighborhoods"] as! [Any]!,
                                                     on: searchParams["date"] as! Date!,
                                                     going: searchParams["going"] as! Bool)
            }
        }
    }
    
    @IBAction func didTapFilterUnwind(segue:UIStoryboardSegue) {
    }
    
    
    // MARK: Search methods
    
    func searchedForRide(withCenter center: String, andNeighborhoods neighborhoods: [Any], on date: Date, going: Bool) {
        searchParams = ["center": center,
                        "neighborhoods": neighborhoods,
                        "date": date,
                        "going": going]
        
        performSegue(withIdentifier: "ViewSearchResults", sender: self)
    }
    
}
