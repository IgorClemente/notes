//
//  AddTagViewController.swift
//  Notes
//
//  Created by MACBOOK AIR on 02/03/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import CoreData

class AddTagViewController: UIViewController {

    @IBOutlet weak var tagNameTextField: UITextField?
    
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupButtonItem()
        tagNameTextField?.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(addTag))
    }
    
    @objc private func addTag() {
        guard let text = self.tagNameTextField?.text,
              !text.isEmpty,
              let context = self.managedObjectContext else {
            return
        }

        let tag  = Tag(context: context)
        tag.name = text
        
        _ = navigationController?.popViewController(animated: true)
    }
}
