class TabBarController: UITabBarController {
    
    var allRidesViewController: AllRidesViewController!
    var allRidesNavigationController: UINavigationController!
    
    var myRidesViewController: MyRidesViewController!
    var myRidesNavigationController: UINavigationController!
    
    var menuViewController: MenuViewController!
    var menuNavigationController: UINavigationController!
    
    class func instance() -> TabBarController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabViewController") as! TabBarController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewControllers = viewControllers else {
            return
        }
        
        for viewController in viewControllers {
            if viewController is UINavigationController,
                let navigationController = viewController as? UINavigationController,
                let viewController = navigationController.topViewController {
                
                if viewController is AllRidesViewController {
                    self.allRidesNavigationController = navigationController
                    self.allRidesViewController = viewController as! AllRidesViewController
                } else if viewController is MyRidesViewController {
                    self.myRidesNavigationController = navigationController
                    self.myRidesViewController = viewController as! MyRidesViewController
                } else if viewController is MenuViewController {
                    self.menuNavigationController = navigationController
                    self.menuViewController = viewController as! MenuViewController
                }
            }
        }
    }
    
}
