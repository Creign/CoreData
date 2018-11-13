//
//  ViewController.swift
//  CoreDataEx
//
//  Created by Excell on 12/11/2018.
//  Copyright © 2018 Excell. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var products = [Product]()
    
    lazy var TextFields: [UITextField] = {
        var txtProdID = UITextField()
        var txtProdName = UITextField()
        var txtProdPrice = UITextField()
        
        return [txtProdID, txtProdName, txtProdPrice]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        print("File Path: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
        
        fetchProducts()
    }
    
    @IBAction func btnAdd(_ sender: Any) {
        var txtFields = TextFields
        
        let alert = UIAlertController(title: "Add new prduct:", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default, handler: {
            action in
            self.createProduct(id: Int(txtFields[0].text!)!,
                             name: txtFields[1].text!,
                             price: Double(txtFields[2].text!)!)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        for i in 0 ..< txtFields.count {
            alert.addTextField(configurationHandler: {
                textField in
                
                switch i {
                case 0:
                    textField.placeholder = "Product ID"
                    break
                case 1:
                    textField.placeholder = "Product Name"
                    break
                case 2:
                    textField.placeholder = "Product Price"
                    break
                default:
                    break
                }
                
                txtFields[i] = textField
            })
        }

        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showUpdateDeleteAlert(id: Int) {
        var txtFields = TextFields
        
        let alert = UIAlertController(title: "Modify Product:", message: "", preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "Update", style: .default, handler: {
            action in
            self.updateProduct(id: id,
                               name: txtFields[1].text!,
                               price: Double(txtFields[2].text!)!)
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            action in
            self.deleteProduct(id: id)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        for i in 0 ..< txtFields.count {
            alert.addTextField(configurationHandler: {
                textField in
                
                switch i {
                case 0:
                    textField.text = String(self.products[id].id)
                    textField.isEnabled = false
                    break
                case 1:
                    textField.text = self.products[id].name
                    break
                case 2:
                    textField.text = String(self.products[id].price)
                    break
                default:
                    break
                }
                
                txtFields[i] = textField
            })
        }
        
        alert.addAction(updateAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Create new product
    func createProduct(id: Int, name: String, price: Double) {
        let newProd = Product(context: context)
        
        newProd.id = Int32(id)
        newProd.name = name
        newProd.price = price
        
        saveContext()
    }
    
    //MARK: - Update a product
    func updateProduct(id: Int, name: String, price: Double) {
        products[id].name = name
        products[id].price = price
        
        saveContext()
    }
    
    //MARK: - Save context
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        fetchProducts()
    }
    
    //MARK: - Delete a product
    func deleteProduct(id: Int) {
        context.delete(products[id])
    }
    
    //MARK: - Get all products
    func fetchProducts(request: NSFetchRequest<Product> = Product.fetchRequest()) {
        do {
            try products = context.fetch(request)
        } catch {
            print("Error fetching results: \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - Table View Data Source
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! ProductsTableViewCell
        
        cell.lblID.text = "Product ID: \(String(products[indexPath.row].id))"
        cell.lblName.text = "Product Name: \(products[indexPath.row].name!)"
        cell.lblPrice.text = "Product Price: \(String(products[indexPath.row].price))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showUpdateDeleteAlert(id: indexPath.row)
    }
}

//MARK: - Table View Delegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

//MARK:- Search Bar Delegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        let predicate = NSPredicate(format: "id CONTAINS %@ OR name CONTAINS[cd] %@ OR price CONTAINS %@", searchBar.text!, searchBar.text!, searchBar.text!)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        
        fetchProducts(request: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetchProducts()

            DispatchQueue.main.async(execute: {
                searchBar.resignFirstResponder()
            })
        }
    }
}

