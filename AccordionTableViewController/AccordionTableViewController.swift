import UIKit

class AccordionTableViewController: UIViewController {

    let tableView = UITableView(frame: .zero)

    let defaultItems = ["Pizza", "Pasta", "Curry"]
    private lazy var items = defaultItems
    let subItems = ["Small", "Medium", "Large"]

    private var open = false

    let cellIdentifier = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        [
            NSLayoutConstraint.Attribute.top,
            NSLayoutConstraint.Attribute.right,
            NSLayoutConstraint.Attribute.bottom,
            NSLayoutConstraint.Attribute.left,
        ]
            .forEach { attribute in
                view.addConstraint(
                    NSLayoutConstraint(
                        item: tableView,
                        attribute: attribute,
                        relatedBy: .equal,
                        toItem: view,
                        attribute: attribute,
                        multiplier: 1,
                        constant: 0
                    )
                )
            }
    }

    func item(for indexPath: IndexPath) -> String? {
        guard indexPath.row < items.count else { return .none }
        return items[indexPath.row]
    }
}

extension AccordionTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        guard let item = item(for: indexPath) else { return cell }

        cell.textLabel?.text = item

        return cell
    }
}

extension AccordionTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if open {
            let newItems = defaultItems
            tableView.performBatchUpdates(
                {
                    tableView.deleteRows(
                        at: [
                            IndexPath(row: 3, section: 0),
                            IndexPath(row: 4, section: 0),
                            IndexPath(row: 5, section: 0)
                        ],
                        with: .top
                    )
                    items = newItems
            },
                completion: { [weak self] done in
                    if done { self?.open = false }
                }
            )
        } else {
            let newItems = defaultItems + subItems
            tableView.performBatchUpdates(
                {
                    tableView.insertRows(
                        at: [
                            IndexPath(row: 3, section: 0),
                            IndexPath(row: 4, section: 0),
                            IndexPath(row: 5, section: 0)
                        ],
                        with: .top
                    )
                    items = newItems
                },
                completion: { [weak self] done in
                    if done { self?.open = true }
                }
            )
        }
    }
}
