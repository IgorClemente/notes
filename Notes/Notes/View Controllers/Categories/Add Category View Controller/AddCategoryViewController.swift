//
//  AddCategoryViewController.swift
//  Notes
//
//  Created by MACBOOK AIR on 26/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit
import CoreData

class AddCategoryViewController: UIViewController {

    @IBOutlet weak var nameCategoryTextField: UITextField?
    
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let textField = self.nameCategoryTextField else { return }
        
        title = "Adicionar Categoria"
        
        setupView()
        textField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(save(_:)))
    }
    
    @objc private func save(_ sender:UIBarButtonItem) {
        guard let text = self.nameCategoryTextField?.text, !text.isEmpty,
              let context = self.managedObjectContext else {
            showAlert(with: "Sem nome", and: "Para adicionar uma categoria, primeiro adicione um nome")
            return
        }
        
        let category  = Category(context: context)
        category.name = text
        
        _ = navigationController?.popViewController(animated: true)
    }
}
