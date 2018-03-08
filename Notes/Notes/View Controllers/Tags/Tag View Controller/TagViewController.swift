//
//  TagViewController.swift
//  Notes
//
//  Created by MACBOOK AIR on 02/03/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit

class TagViewController: UIViewController {

    @IBOutlet weak var tagNameTextField: UITextField?
    
    var tag: Tag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextField()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupTextField() {
        guard let name = tag?.name else { return }
        tagNameTextField?.text = name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let tag  = self.tag,
              let text = self.tagNameTextField?.text,
              !text.isEmpty else {
            return
        }
        tag.name = text
    }
}
