import UIKit

class AccordionTableViewController: UIViewController {

    struct Item {
        let text: String
        let children: [Item]
        let open: Bool
    }

    let tableView = UITableView(frame: .zero)

    let items = [
        Item(
            text: "Pizza",
            children: [
                Item(text: "Margherita", children: [], open: false),
                Item(text: "Pepperoni", children: [], open: false)
            ],
            open: true
        ),
        Item(
            text: "Pasta",
            children: [],
            open: true
        ),
        Item(
            text: "Curry",
            children: [
                Item(text: "Mild", children: [], open: false),
                Item(text: "Spicy", children: [], open: false)
            ],
            open: false
        ),
    ]


    var displayItems: [Item] {
        return items.flatMap(flatten)
    }

    // TODO: flatten is the wrong name for this
    private func flatten(item: Item) -> [Item] {
        guard item.children.isEmpty == false else { return [item] }

        guard item.open else { return [item] }

        return [item] + item.children.flatMap(flatten)
    }

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

    func item(for indexPath: IndexPath) -> Item? {
        guard indexPath.row < displayItems.count else { return .none }
        return displayItems[indexPath.row]
    }
}

extension AccordionTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        guard let item = item(for: indexPath) else { return cell }

        cell.textLabel?.text = item.text

        return cell
    }
}

extension AccordionTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
