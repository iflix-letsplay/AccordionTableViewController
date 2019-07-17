import UIKit

class AccordionTableViewController: UIViewController {

    struct Item {
        enum Kind {
            case actionable(action: () -> Void)
            case container(items: [Item], expanded: Bool)
        }

        let text: String
        let kind: Kind
    }

    let tableView = UITableView(frame: .zero)

    let items = [
        Item(
            text: "Pizza",
            kind: .container(
                items: [
                    Item(text: "Margherita", kind: .actionable(action: {})),
                    Item(text: "Pepperoni", kind: .actionable(action: {}))
                ],
                expanded: false
            )
        ),
        Item(
            text: "Pasta",
            kind: .actionable(action: {})
        ),
        Item(
            text: "Curry",
            kind: .container(
                items: [
                    Item(text: "Mild", kind: .actionable(action: {})),
                    Item(text: "Spicy", kind: .actionable(action: {}))
                ],
                expanded: true
            )
        )
    ]

    var displayItems: [Item] {
        return items.flatMap(flatten)
    }

    // TODO: flatten is the wrong name for this
    private func flatten(item: Item) -> [Item] {
        switch item.kind {
        case .actionable(_):
            return [item]
        case .container(let items, let expanded):
            guard expanded else { return [item] }
            return [item] + items.flatMap(flatten)
        }
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
