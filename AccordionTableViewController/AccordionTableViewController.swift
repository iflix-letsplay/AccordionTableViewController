import UIKit

// Using `CustomStringConvertible` so that we can easily set the text of the cell.
// Later on we'll define some kind of closure to select and configure a given cell based on an
// item `T`.
class AccordionTableViewController<T: Equatable & CustomStringConvertible>: UIViewController, UITableViewDataSource, UITableViewDelegate {

    struct Banana {

        struct Node {
            let item: T
            let children: [Node]
            let open: Bool
        }

        struct DisplayableNode {
            let node: Node
            let depth: Int
            let parent: Node?
        }

        // TODO: better name?
        let items: [Node]

        /// A flattened representation of the items to make displaying in a table view easier
        var itemsToDisplay: [DisplayableNode] {
            return items.flatMap { flatten(item: $0) }
        }

        // TODO: flatten is the wrong name for this
        private func flatten(
            item: Node,
            depth: Int = 0,
            parent: Node? = .none
        ) -> [DisplayableNode] {
            guard item.children.isEmpty == false else {
                return [DisplayableNode(node: item, depth: depth, parent: parent)]
            }

            guard item.open else {
                return [DisplayableNode(node: item, depth: depth, parent: parent)]
            }

            return [DisplayableNode(node: item, depth: depth, parent: parent)]
                + item.children.flatMap { flatten(item: $0, depth: depth + 1, parent: item) }
        }

        func item(for indexPath: IndexPath) -> DisplayableNode? {
            guard indexPath.row < itemsToDisplay.count else { return .none }
            return itemsToDisplay[indexPath.row]
        }

        enum Operation {
            case leafSelected(T)
            case redraw(insert: [Int], delete: [Int])
        }

        func updated(bySelecting indexPath: IndexPath) -> (Banana, Operation) {
            guard let displayItem = item(for: indexPath) else {
                return (self, .redraw(insert: [], delete: []))
            }

            guard displayItem.parent == nil else {
                // we have a soft rule for the depth of the tree being 2, so we can assume that if
                // the item has a parent then it's not one that should be expanded/collapsed
                return (self, .leafSelected(displayItem.node.item))
            }

            // if there's no parent then we have a root item to expand/collapse
            guard displayItem.node.children.isEmpty == false else {
                return (self, .leafSelected(displayItem.node.item))
            }

            guard let index = items.firstIndex(where: { $0.item == displayItem.node.item }) else {
                return (self, .leafSelected(displayItem.node.item))
            }

            guard let displayIndex = itemsToDisplay.firstIndex(where: { $0.node.item == displayItem.node.item }) else {
                return (self, .leafSelected(displayItem.node.item))
            }

            let newItem = Banana.Node(
                item: displayItem.node.item,
                children: displayItem.node.children,
                open: !displayItem.node.open // TODO: add `flipped` Bool extension
            )

            var newItems = items
            newItems.remove(at: index)
            newItems.insert(newItem, at: index)

            let indexes = ((displayIndex + 1)..<(displayIndex + 1 + displayItem.node.children.count))

            if displayItem.node.open {
                return (Banana(items: newItems), .redraw(insert: [], delete: Array(indexes)))
            } else {
                return (Banana(items: newItems), .redraw(insert: Array(indexes), delete: []))
            }
        }
    }

    let tableView = UITableView(frame: .zero)

    var banana: Banana
    // Defined as configurable after init so that we can refer to `self` in it and do things like
    // presenting alerts from it.
    // Not sure if that's a good approach, will have to see...
    var onSelect: ((T) -> Void)?

    let cellIdentifier = "cell"

    init(banana: Banana) {
        self.banana = banana
        super.init(nibName: .none, bundle: .none)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
//}
//
//extension AccordionTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banana.itemsToDisplay.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        guard let item = banana.item(for: indexPath) else { return cell }

        cell.textLabel?.text = item.node.item.description

        return cell
    }
//}
//
//extension AccordionTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let (newBanana, operation) = banana.updated(bySelecting: indexPath)

        switch operation {
        case .leafSelected(let item): onSelect?(item)
        case .redraw(let indexesToInsert, let indexesToRemove):
            tableView.performBatchUpdates(
                {
                    tableView.deleteRows(
                        at: indexesToRemove.map { IndexPath(row: $0, section: 0) },
                        with: .top
                    )
                    tableView.insertRows(
                        at: indexesToInsert.map { IndexPath(row: $0, section: 0) },
                        with: .top
                    )

                    banana = newBanana
                },
                completion: .none
            )
        }
    }
}
