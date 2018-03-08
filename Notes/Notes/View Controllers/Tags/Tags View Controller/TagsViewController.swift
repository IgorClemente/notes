//
//  TagsViewController.swift
//  Notes
//
//  Created by MACBOOK AIR on 02/03/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import CoreData

class TagsViewController: UIViewController {

    @IBOutlet weak var tagsTableView: UITableView?
    @IBOutlet weak var statusLabel: UILabel?
    
    var note: Note?
    
    private enum Segue {
        static let AddTag = "AddTag"
        static let Edit   = "Edit"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchTags()
        self.setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private var hasTags: Bool {
        guard let tags = fetchedResultsController.fetchedObjects else { return false }
        return tags.count > 0
    }
    
    private func fetchTags() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unable to perform fetch")
            print("\(error) \(error.localizedDescription)")
        }
    }
    
    private func setupView() {
        guard let tableView   = self.tagsTableView,
              let statusLabel = self.statusLabel else {
            return
        }
        tableView.isHidden   = !hasTags
        statusLabel.isHidden = hasTags
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Tag> = {
        guard let context = self.note?.managedObjectContext else { return NSFetchedResultsController() }
        
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tag.name),
                                                         ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.AddTag:
            guard let destination = segue.destination as? AddTagViewController else {
                return
            }
            destination.managedObjectContext = note?.managedObjectContext
            
        case Segue.Edit:
            guard let destination = segue.destination as? TagViewController,
                  let tableView   = self.tagsTableView else {
                return
            }
            
            guard let cell = sender as? TagTableViewCell,
                  let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            
            let tag = fetchedResultsController.object(at: indexPath)
            destination.tag = tag
            
        default:
            break
        }
    }
}

extension TagsViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func configure(_ cell: TagTableViewCell, at indexPath: IndexPath) {
        let tag = fetchedResultsController.object(at: indexPath)
        
        cell.tagName?.text = tag.name
        
        if let containsTag = note?.tags?.contains(tag), containsTag == true {
           cell.tagName?.textColor = .bitterSweet
        } else {
            cell.tagName?.textColor = .black
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TagTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? TagTableViewCell else {
            fatalError("Unexpected value index path")
        }
        self.configure(cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let tag = fetchedResultsController.object(at: indexPath)
        
        if let containsTag = note?.tags?.contains(tag), containsTag == true {
            note?.removeFromTags(tag)
        } else {
            note?.addToTags(tag)
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let tag = fetchedResultsController.object(at: indexPath)
        note?.managedObjectContext?.delete(tag)
    }
}


extension TagsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let tableView = self.tagsTableView else { return }
        
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let tableView = self.tagsTableView else { return }
        
        tableView.endUpdates()
        setupView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let tableView = self.tagsTableView else { return }
        
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            tableView.insertRows(at: [indexPath], with: .fade)
            
        case .update:
            guard let indexPath = indexPath else { return }
            if let cell = tableView.cellForRow(at: indexPath) as? TagTableViewCell {
               configure(cell, at: indexPath)
            }
            
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
