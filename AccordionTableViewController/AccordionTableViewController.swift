import UIKit

protocol AccordionTableViewControllerDelegate: class {

    func tableViewController(
        _ tableViewController: AccordionTableViewController,
        didSelect item: AccordionTableViewController.Item
    )
}

class AccordionTableViewController: UIViewController {

    struct Item: Equatable {
        let text: String
        let children: [Item]
        let open: Bool
    }

    struct DisplayItem: Equatable {
        let item: Item
        let parent: Item?

        var text: String { return item.text }
    }

    let tableView = UITableView(frame: .zero)

    let collapsedItems = [
        Item(
            text: "Pizza",
            children: [
                Item(text: "Margherita", children: [], open: false),
                Item(text: "Pepperoni", children: [], open: false)
            ],
            open: false
        ),
        Item(
            text: "Pasta",
            children: [],
            open: false
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

    lazy var items = collapsedItems

    var displayItems: [DisplayItem] {
        return items.flatMap { flatten(item: $0) }
    }

    weak var delegate: AccordionTableViewControllerDelegate?

    // TODO: flatten is the wrong name for this
    private func flatten(item: Item, parent: Item? = .none) -> [DisplayItem] {
        guard item.children.isEmpty == false else {
            return [DisplayItem(item: item, parent: .none)]
        }

        guard item.open else {
            return [DisplayItem(item: item, parent: .none)]
        }

        return [DisplayItem(item: item, parent: parent)] + item.children.flatMap { flatten(item: $0, parent: item) }
    }

    let cellIdentifier = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

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

    func item(for indexPath: IndexPath) -> DisplayItem? {
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

        guard let displayItem = item(for: indexPath) else { return }

        if let _ = displayItem.parent {
            // TODO:
        } else {
            // if there's no parent then we have a root item to expand/collapse
            guard displayItem.item.children.isEmpty == false else {
                delegate?.tableViewController(self, didSelect: displayItem.item)
                return
            }

            guard let index = items.firstIndex(where: { $0.text == displayItem.item.text }) else { return }
            guard let displayIndex = displayItems.firstIndex(where: { $0.text == displayItem.item.text }) else { return }

            let newItem = Item(
                text: displayItem.item.text,
                children: displayItem.item.children,
                open: !displayItem.item.open // TODO: add `flipped` Bool extension
            )

            var newItems = items
            newItems.remove(at: index)
            newItems.insert(newItem, at: index)

            let indexes = ((displayIndex + 1)..<(displayIndex + 1 + displayItem.item.children.count))

            if displayItem.item.open {
                tableView.performBatchUpdates(
                    {
                        indexes.forEach { rowIndex in
                            tableView.deleteRows(at: [IndexPath(row: rowIndex, section: 0)], with: .top)
                        }
                        items = newItems
                },
                    completion: .none
                )
            } else {
                tableView.performBatchUpdates(
                    {
                        indexes.forEach { rowIndex in
                            tableView.insertRows(at: [IndexPath(row: rowIndex, section: 0)], with: .top)
                        }
                        items = newItems
                },
                    completion: .none
                )
            }
        }
    }
}

extension AccordionTableViewController: AccordionTableViewControllerDelegate {

    func tableViewController(_ tableViewController: AccordionTableViewController, didSelect item: AccordionTableViewController.Item) {
        let alert = UIAlertController(
            title: .none,
            message: item.text,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: .none))

        present(alert, animated: true, completion: .none)
    }
}
