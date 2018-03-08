//
//  CategoryViewController.swift
//  Notes
//
//  Created by MACBOOK AIR on 26/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {

    @IBOutlet weak var categoryNameTextField: UITextField?
    @IBOutlet weak var categoryColorView: UIView?
    
    var category: Category?
    
    private enum Segue {
        static let Color = "Color"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Editar Categoria"
        
        setupView()
        updateColorView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let text = self.categoryNameTextField?.text, !text.isEmpty else { return }
        
        category?.name = text
    }
    
    private func setupView() {
        guard let textField = self.categoryNameTextField,
              let category  = self.category else {
            return
        }
        textField.text = category.name
    }
    
    private func updateColorView() {
        guard let colorView = self.categoryColorView else { return }
        
        colorView.backgroundColor = category?.color ?? .white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.Color:
            guard let destination = segue.destination as? ColorViewController else {
                return
            }
            destination.color    = category?.color ?? .white
            destination.delegate = self
            
        default:
            break
        }
    }
}

extension CategoryViewController: ColorViewControllerDelegate {
    
    func configure(_ controller: ColorViewController, didPick color: UIColor) {
        category?.color = color
        updateColorView()
    }
}
