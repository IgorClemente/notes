//
//  NoteViewController.swift
//  Notes
//
//  Created by MACBOOK AIR on 19/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField?
    @IBOutlet weak var contentsTextView: UITextView?
    @IBOutlet weak var categoryLabel: UILabel?
    @IBOutlet weak var tagsLabel: UILabel?
    
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Editar nota"
        
        setupView()
        setupNotificationHandling()
    }
    
    private enum Segue {
        static let Categories = "Categories"
        static let Tags = "Tags"
    }
    
    private func setupView() {
        setupTitleTextField()
        setupContentsTextView()
        updateCategoryLabel()
        updateTagsLabel()
    }

    private func setupTitleTextField() {
        titleTextField?.text = note?.title
    }
    
    private func setupContentsTextView() {
        contentsTextView?.text = note?.contents
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let title = titleTextField?.text, !title.isEmpty {
           note?.title = title
        }
        note?.updateAt = Date()
        note?.contents = contentsTextView?.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(managedObjectContextObjectsDidChange(_:)),
                                       name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                       object: note?.managedObjectContext)
    }
    
    @objc private func managedObjectContextObjectsDidChange(_ notification:Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> else { return }
        
        if (updates.filter { return $0 == note }).count > 0 {
           updateCategoryLabel()
           updateTagsLabel()
        }
    }
    
    private func updateCategoryLabel() {
        categoryLabel?.text = note?.category?.name ?? "No Category"
    }
    
    private func updateTagsLabel() {
        tagsLabel?.text = note?.alphabetizedTagsAsString ?? "Não possui tags"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.Categories:
            guard let destination = segue.destination as? CategoriesViewController else {
                return
            }
            destination.note = note
         
        case Segue.Tags:
            guard let destination = segue.destination as? TagsViewController else {
                return
            }
            destination.note = note
            
        default:
            break
        }
    }
}
