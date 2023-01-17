//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jeevan Chandra Joshi on 17/01/23.
//

import ChameleonFramework
import CoreData
import SwipeCellKit
import UIKit

class CategoryViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let addButton = UIBarButtonItem()
    let searchBar = UISearchBar()

    var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Todoey"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = addButton
        navigationItem.titleView = searchBar

        searchBar.delegate = self

        tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.separatorStyle = .none

        addButton.image = UIImage(systemName: "plus")
        addButton.target = self
        addButton.action = #selector(addButtonPressed)

        loadCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        let color = UIColor.systemCyan
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = color
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = ContrastColorOf(color, returnFlat: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = categories[indexPath.row].title
        if let color = UIColor(hexString: categories[indexPath.row].color!) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemViewController = ItemViewController(category: categories[indexPath.row])
        navigationController?.pushViewController(itemViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    @objc func addButtonPressed() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Category", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { _ in
            if let category = textField.text {
                let newCategory = Category(context: self.context)
                newCategory.title = category
                newCategory.color = UIColor.randomFlat().hexValue()
                self.categories.append(newCategory)
                self.saveCategories()
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category..."
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension CategoryViewController {
    func loadCategories(_ request: NSFetchRequest<Category> = Category.fetchRequest(), _ predicate: NSPredicate? = nil) {
        request.predicate = predicate
        do {
            categories = try context.fetch(request)
        } catch {
            handleError(error)
        }
        tableView.reloadData()
    }

    func saveCategories() {
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

extension CategoryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadCategories(request, predicate)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadCategories()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

extension CategoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [self] _, _ in
            context.delete(categories[indexPath.row])
            categories.remove(at: indexPath.row)
            saveCategories()
        }

        deleteAction.image = UIImage(systemName: "trash")

        return [deleteAction]
    }
}
