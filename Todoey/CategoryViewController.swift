//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jeevan Chandra Joshi on 17/01/23.
//

import CoreData
import UIKit

class CategoryViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let addButton = UIBarButtonItem()
    let backButton = UIBarButtonItem()
    let searchBar = UISearchBar()

    var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Categories"
        navigationItem.rightBarButtonItem = addButton
        navigationItem.titleView = searchBar
        navigationItem.leftBarButtonItem = backButton

        searchBar.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")

        addButton.image = UIImage(systemName: "plus")
        addButton.target = self
        addButton.action = #selector(addButtonPressed)

        backButton.image = UIImage(systemName: "chevron.left")
        backButton.target = self
        backButton.tintColor = .systemBackground

        loadCategories()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].title
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemViewController = ItemViewController()
        if let indexPath = tableView.indexPathForSelectedRow {
            itemViewController.category = categories[indexPath.row]
            navigationController?.pushViewController(itemViewController, animated: true)
        }
    }

    @objc func addButtonPressed() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Category", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { _ in
            if let category = textField.text {
                let newCategory = Category(context: self.context)
                newCategory.title = category
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
