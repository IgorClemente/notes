//
//  ViewController.swift
//  Notes
//
//  Created by MACBOOK AIR on 12/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var statusView: UIView?
    
    var coreDataManager: CoreDataManager = CoreDataManager(modelName: "Notes")
    
    /**
    private var notes: [Note]? {
        didSet {
            updateView()
        }
    }
    **/
    
    private var hasNotes: Bool {
        guard let fetchObjects = fetchResultsController.fetchedObjects else { return false }
        return fetchObjects.count > 0
    }
    
    private lazy var fetchResultsController: NSFetchedResultsController<Note> = {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.updateAt), ascending: false)]
        
        let context = self.coreDataManager.mainManagedObjectContext
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                managedObjectContext: context,
                                                                sectionNameKeyPath: nil,
                                                                cacheName: nil)
        fetchResultsController.delegate = self
        return fetchResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notas"
        
        fetchNotes()
        //setupNotificationHandling()
        updateView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func updateView() {
        guard let tableView = self.tableView, let statusView = self.statusView else { return }
        
        tableView.isHidden  = !hasNotes
        statusView.isHidden = hasNotes
    }
    
    private func fetchNotes() {
        do {
            try self.fetchResultsController.performFetch()
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error) \(error.localizedDescription)")
        }
        /**
        guard let tablewView = self.tableView else { return }
        **/
        /**
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.updateAt),
                                                         ascending: false) ]
        coreDataManager.managedObjectContext.performAndWait {
            do {
               let notes = try fetchRequest.execute()
               self.notes = notes
               tablewView.reloadData()
            } catch {
               let fetchError = error as NSError
               print("Unable to Execute Fetch Request")
               print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        **/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            case "Segue.AddNote":
                guard let destination = segue.destination as? AddNoteViewController else {
                    return
                }
                destination.managedObjectContext = coreDataManager.mainManagedObjectContext
            case "Segue.UpdateNote":
                guard let destination = segue.destination as? NoteViewController,
                      let note        = sender as? Note else {
                    return
                }
                destination.note = note
            default:
                break
        }
    }
    
    /**
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(_:)),
                                       name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                       object: coreDataManager.managedObjectContext)
    }
    
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        var notes = fetchResultsController.fetchedObjects
        var notesDidChange = false
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
           for insert in inserts {
               if let note = insert as? Note {
                  notes?.append(note)
                  notesDidChange = true
               }
           }
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
           for delete in deletes {
               if let note = delete as? Note {
                  if let index = notes?.index(of: note) {
                     notes?.remove(at: index)
                     notesDidChange = true
                  }
               }
           }
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
           for update in updates {
               if let _ = update as? Note {
                  notesDidChange = true
               }
           }
        }
        
        if notesDidChange {
           guard let tableView = self.tableView else { return }
           notes?.sort(by: { (note1, note2) -> Bool in
                return note1.updateAtAsDate > note2.updateAtAsDate
           })
           
           tableView.reloadData()
           updateView()
        }
    }
    **/
}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configure(_ cell:NoteTableViewCell, at indexPath:IndexPath) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy HH:mm:ss"
        
        let note = fetchResultsController.object(at: indexPath)
        
        cell.titleLabel?.text    = note.title
        cell.contentsLabel?.text = note.contents
        cell.updateAtLabel?.text = formatter.string(from: note.updateAtAsDate)
        cell.tagsLabel?.text     = note.alphabetizedTagsAsString ?? "Não possui tags"
        
        if let color = note.category?.color {
           cell.categoryColorView?.backgroundColor = color
        } else {
            cell.categoryColorView?.backgroundColor = .white
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? NoteTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        configure(cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let note = fetchResultsController.object(at: indexPath)
        performSegue(withIdentifier: "Segue.UpdateNote", sender: note)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let note = fetchResultsController.object(at: indexPath)
        note.managedObjectContext?.delete(note)
    }
}

extension NotesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
               tableView?.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
               tableView?.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath,let cell = tableView?.cellForRow(at: indexPath) as? NoteTableViewCell {
               configure(cell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
               tableView?.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
               tableView?.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }
}

