//
//  AddNoteViewController.swift
//  Notes
//
//  Created by MACBOOK AIR on 18/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import CoreData

class AddNoteViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField?
    @IBOutlet weak var contentsTextView: UITextView?
    
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Adicionar Nota"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let managedObjectContext = self.managedObjectContext else { return }
        
        guard let title    = self.titleTextField?.text, !title.isEmpty,
              let contents = self.contentsTextView?.text, !contents.isEmpty else {
            showAlert(with: "Nota sem título", and: "A nota não possui título")
            return
        }
        
        let note = Note(context: managedObjectContext)
        note.createAt = Date()
        note.updateAt = Date()
        note.title    = title
        note.contents = contents
        _ = navigationController?.popViewController(animated: true)
    }
}

extension UIViewController {
    func showAlert(with title:String, and message:String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
