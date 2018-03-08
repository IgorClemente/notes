//
//  CategoriesViewController.swift
//  Notes
//
//  Created by MACBOOK AIR on 26/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UIViewController {

    @IBOutlet weak var categoriesTableView: UITableView?
    @IBOutlet weak var notFoundMessageLabel: UILabel?
    
    var note: Note? 
    
    private enum Segue {
        static let AddCategory  = "AddCategory"
        static let EditCategory = "EditCategory"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Categorias"
        
        fetchCategories()
        setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private var hasCategories: Bool {
        guard let categories = fetchedResultsController.fetchedObjects else { return false }
        return categories.count > 0
    }
    
    private func setupViews() {
        updateNavigationView()
        updateViews()
    }
    
    private func updateNavigationView() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                 target: self,
                                                                 action: #selector(addCategory(_:)))
    }
    
    private func updateViews() {
        guard let tableView = self.categoriesTableView,
              let messageLabel = self.notFoundMessageLabel else {
            return
        }
        
        tableView.isHidden    = !hasCategories
        messageLabel.isHidden = hasCategories
    }
    
    @objc private func addCategory(_ sender:UIBarButtonItem) {
        performSegue(withIdentifier: Segue.AddCategory, sender: nil)
    }
    
    private func fetchCategories() {
        do {
           try self.fetchedResultsController.performFetch()
        } catch {
           print("Unable to Perform Fetch")
           print("\(error) \(error.localizedDescription)")
        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        guard let managedObjectContext = note?.managedObjectContext else { return NSFetchedResultsController() }
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Category.name), ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.AddCategory:
            guard let destination = segue.destination as? AddCategoryViewController,
                  let note = self.note else {
                return
            }
            destination.managedObjectContext = note.managedObjectContext
        case Segue.EditCategory:
            guard let destination = segue.destination as? CategoryViewController,
                  let tableView   = self.categoriesTableView else {
                return
            }
            
            guard let cell = sender as? CategoryTableViewCell,
                  let indexPath = tableView.indexPath(for: cell) else {
                return
                
            }
            let category  = fetchedResultsController.object(at: indexPath)
            destination.category = category
        default:
            break
        }
    }
}

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func configure(_ cell:CategoryTableViewCell, at indexPath:IndexPath) {
        let category = fetchedResultsController.object(at: indexPath)
        cell.nameCategoryLabel?.text = category.name
        
        if note?.category == category {
            cell.nameCategoryLabel?.textColor = UIColor.bitterSweet
        } else {
            cell.nameCategoryLabel?.textColor = .black
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? CategoryTableViewCell else {
            fatalError("Unexpected value index path")
        }
        configure(cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableView = self.categoriesTableView else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        let category = fetchedResultsController.object(at: indexPath)
        note?.category = category
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let category = fetchedResultsController.object(at: indexPath)
        note?.managedObjectContext?.delete(category)
    }
}

extension CategoriesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let tableView = self.categoriesTableView else { return }
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let tableView = self.categoriesTableView else { return }
        tableView.endUpdates()
        
        updateViews()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let tableView = self.categoriesTableView else { return }
        
        switch type {
            
        case .insert:
            guard let indexPath = newIndexPath else { return }
            tableView.insertRows(at: [indexPath], with: .fade)
            
        case .update:
            guard let indexPath = indexPath,
                  let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell else {
                  return
            }
            configure(cell, at: indexPath)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        case .move:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .fade)
        }
    }
}
