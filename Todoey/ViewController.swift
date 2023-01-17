//
//  ViewController.swift
//  Todoey
//
//  Created by Jeevan Chandra Joshi on 17/01/23.
//

import UIKit

class ViewController: UITableViewController {
    let addButton = UIBarButtonItem()

    var itemsArray: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Todoey"
        navigationItem.rightBarButtonItem = addButton

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TodoCell")

        addButton.image = UIImage(systemName: "plus")
        addButton.target = self
        addButton.action = #selector(addButtonPressed)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        cell.textLabel?.text = itemsArray[indexPath.row].title
        cell.accessoryType = itemsArray[indexPath.row].isDone ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemsArray[indexPath.row].isDone.toggle()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }

    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { _ in
            if let item = textField.text {
                let newItem = Item()
                newItem.title = item
                self.itemsArray.append(newItem)
                self.tableView.reloadData()
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item..."
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}
