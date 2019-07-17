import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = AccordionTableViewController<String>(
            banana: AccordionTableViewController.Banana(
                items: [
                    AccordionTableViewController.Banana.Node(
                        item: "Pizza",
                        children: [
                            AccordionTableViewController.Banana.Node(
                                item: "Margherita", children: [], open: false
                            ),
                            AccordionTableViewController.Banana.Node(
                                item: "Pepperoni", children: [], open: false
                            )
                        ],
                        open: true
                    ),
                    AccordionTableViewController.Banana.Node(
                        item: "Pasta", children: [], open: false
                    ),
                    AccordionTableViewController.Banana.Node(
                        item: "Curry",
                        children: [
                            AccordionTableViewController.Banana.Node(
                                item: "Mild", children: [], open: false
                            ),
                            AccordionTableViewController.Banana.Node(
                                item: "Spicy", children: [], open: false
                            )
                        ],
                        open: false
                    ),
                ]
            )
        )

        vc.onSelect = { item in
            let alert = UIAlertController(
                title: .none,
                message: item,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: .none))

            vc.present(alert, animated: true, completion: .none)
        }
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        return true
    }
}
