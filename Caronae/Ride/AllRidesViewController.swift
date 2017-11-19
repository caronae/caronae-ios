import UIKit

class AllRidesViewController: RideListController, SearchRideDelegate {
    let userDefaults = UserDefaults.standard
    var searchParams = FilterParameters()
    var filterParams = FilterParameters()
    var pagination = PaginationState()
    
    fileprivate var lastUpdate = Date.distantPast

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.view.backgroundColor = UIColor.white
        navigationItem.titleView = UIImageView(image: UIImage(named: "NavigationBarLogo"))
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.reloadRidesIfNecessary), name: .UIApplicationWillEnterForeground, object: nil)
        
        // Setting up infinite scroll
        tableView.infiniteScrollTriggerOffset = 500
        
        tableView.addInfiniteScroll { tableView in
            self.loadAllRides() {
                tableView.finishInfiniteScroll()
            }
        }
        
        tableView.setShouldShowInfiniteScrollHandler { _ in
            self.pagination.directionGoing = self.ridesDirectionGoing
            return self.pagination.hasNextPage
        }
        
        filterIsEnabled = userDefaults.bool(forKey: CaronaePreferenceFilterIsEnabledKey)
        
        if filterIsEnabled {
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
    
    override func refreshTable() {
        pagination = PaginationState()
        loadAllRides()
    }
    
    
    // MARK: Rides methods
    
    func loadAllRides(direction: Bool? = nil, _ completionHandler: (() -> Void)? = nil) {
        if tableView.backgroundView != nil {
            tableView.backgroundView = loadingLabel
        }
        
        filterParams.going = direction ?? ridesDirectionGoing
        pagination.directionGoing = filterParams.going!
        let page = pagination.nextPage
        
        RideService.instance.getRides(page: page, filterParameters: filterParams, success: { rides, lastPage in
            
            self.pagination.lastPage = lastPage
            self.pagination.incrementPage()
            
            if page == 1 {
                self.lastUpdate = Date()
                
                // Update rides from both directions
                if direction == nil {
                    self.rides = rides
                } else {
                    var allRides = self.rides
                    allRides.append(contentsOf: rides)
                    self.rides = allRides
                }
                
                if self.rides.count > 0 {
                    self.tableView.tableFooterView = self.tableFooter
                } else {
                    self.tableView.tableFooterView = nil
                }
                
                self.tableView.reloadData()
                
                if direction == nil {
                    // Load first page of the other direction
                    self.loadAllRides(direction: !(self.ridesDirectionGoing))
                }
                
            } else {
                let ridesCount = self.filteredRides.count
                
                // Update rides
                var allRides = self.rides
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
            
            self.refreshControl?.endRefreshing()
            completionHandler?()
        }, error: { error in
            self.refreshControl?.endRefreshing()
            completionHandler?()
            self.loadingFailed(withError: error as NSError)
        })
    }
    
    @objc func reloadRidesIfNecessary() {
        if lastUpdate.timeIntervalSinceNow.isLess(than: -5*60) {
            pagination = PaginationState()
            loadAllRides()
        }
    }
    
    func loadRide(withID id: Int) {
        RideService.instance.getRide(withID: id, success: { ride, availableSlots in
            guard ride.date.isInTheFuture() else {
                CaronaeAlertController.presentOkAlert(withTitle: "Carona encerrada", message: "A carona que você tentou abrir já foi encerrada. Você pode encontrar novas caronas através da busca.")
                return
            }
            
            let rideViewController = RideViewController.instance(for: ride)
            rideViewController.rideIsFull = (availableSlots == 0)
            _ = self.navigationController?.popToRootViewController(animated: false)
            self.navigationController?.pushViewController(rideViewController, animated: true)
        }, error: { error in
            var errorMessage: String!
            
            switch error.caronaeCode {
            case .invalidRide:
                errorMessage = "Talvez a carona que você está procurando não exista mais."
            default:
                errorMessage = "Ocorreu um erro ao tentar carregar a carona. Por favor, tente novamente."
            }
            
            CaronaeAlertController.presentOkAlert(withTitle: "Falha ao carregar carona", message: errorMessage)
        })
    }
    
    func enableFilterRides() {
        guard let campus = userDefaults.string(forKey: CaronaePreferenceLastFilteredCampusKey),
            let centers = userDefaults.stringArray(forKey: CaronaePreferenceLastFilteredCentersKey),
            let zone = userDefaults.string(forKey: CaronaePreferenceLastFilteredZoneKey),
            let neighborhoods = userDefaults.stringArray(forKey: CaronaePreferenceLastFilteredNeighborhoodsKey) else {
                return
        }
        
        if !filterIsEnabled {
            // workaround to not cover cell after enabling filter for the first time
            tableView.setContentOffset(CGPoint.init(x: 0, y: -500), animated: false)
        }
        
        filterIsEnabled = true
        filterParams = FilterParameters(neighborhoods: neighborhoods, zone: zone, hubs: centers, campus: campus)
        filterLabel.text = filterParams.activeFiltersText()
        
        pagination = PaginationState()
        loadAllRides()
    }
    
    func disableFilterRides() {
        userDefaults.set(false, forKey: CaronaePreferenceFilterIsEnabledKey)
        filterIsEnabled = false
        self.filterParams = FilterParameters()
        pagination = PaginationState()
        loadAllRides()
    }
    
    override func didTapClearFilterButton(_ sender: UIButton!) {
        super.didTapClearFilterButton(sender);
        
        disableFilterRides()
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
                searchViewController.searchedForRide(withParameters: searchParams);
            }
        }
    }
    
    @IBAction func didTapFilterUnwind(segue:UIStoryboardSegue) {
    }
    
    
    // MARK: Search methods
    
    func searchedForRide(withParameters parameters: FilterParameters) {
        searchParams = parameters
        
        performSegue(withIdentifier: "ViewSearchResults", sender: self)
    }
    
}
