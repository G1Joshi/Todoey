//
//  ItemViewController.swift
//  Todoey
//
//  Created by Jeevan Chandra Joshi on 17/01/23.
//

import ChameleonFramework
import CoreData
import SwipeCellKit
import UIKit

class ItemViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let addButton = UIBarButtonItem()
    let backButton = UIBarButtonItem()
    let searchBar = UISearchBar()

    var category: Category
    var items = [Item]()

    init(category: Category) {
        self.category = category
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.title
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = addButton
        navigationItem.titleView = searchBar
        navigationItem.leftBarButtonItem = backButton

        searchBar.delegate = self

        tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: "ItemCell")
        tableView.separatorStyle = .none

        addButton.image = UIImage(systemName: "plus")
        addButton.target = self
        addButton.action = #selector(addButtonPressed)

        backButton.image = UIImage(systemName: "chevron.left")
        backButton.target = self
        backButton.action = #selector(backButtonPressed)

        loadItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let color = UIColor(hexString: category.color!) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = color
            appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.tintColor = ContrastColorOf(color, returnFlat: true)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = items[indexPath.row].title
        if let color = UIColor(hexString: category.color!)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        cell.accessoryType = items[indexPath.row].isDone ? .checkmark : .none
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].isDone.toggle()
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    @objc func addButtonPressed() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { _ in
            if let item = textField.text {
                let newItem = Item(context: self.context)
                newItem.title = item
                newItem.isDone = false
                newItem.category = self.category
                self.items.append(newItem)
                self.saveItems()
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item..."
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }

    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}

extension ItemViewController {
    func loadItems(_ request: NSFetchRequest<Item> = Item.fetchRequest(), _ predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "category.title MATCHES %@", category.title!)
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        do {
            items = try context.fetch(request)
        } catch {
            handleError(error)
        }
        tableView.reloadData()
    }

    func saveItems() {
        do {
            try context.save()
        } catch {
            handleError(error)
        }
        tableView.reloadData()
    }

    func handleError(_ error: Error?) {
        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension ItemViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(request, predicate)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

extension ItemViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [self] _, _ in
            context.delete(items[indexPath.row])
            items.remove(at: indexPath.row)
            saveItems()
        }

        deleteAction.image = UIImage(systemName: "trash")

        return [deleteAction]
    }
}
