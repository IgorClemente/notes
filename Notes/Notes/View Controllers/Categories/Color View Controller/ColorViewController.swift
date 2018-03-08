//
//  ColorViewController.swift
//  Notes
//
//  Created by MACBOOK AIR on 27/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit

protocol ColorViewControllerDelegate {
    
    func configure(_ controller:ColorViewController,didPick color:UIColor)
}

class ColorViewController: UIViewController {

    @IBOutlet weak var colorView: UIView?
    
    @IBOutlet weak var redSlider: UISlider?
    @IBOutlet weak var greenSlider: UISlider?
    @IBOutlet weak var blueSlider: UISlider?
    
    var delegate: ColorViewControllerDelegate?
    var color: UIColor = .bitterSweet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Escolher Cor"
        
        setupSliders()
        setupColorView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupSliders() {
        guard let redSlider   = self.redSlider,
              let greenSlider = self.greenSlider,
              let blueSlider  = self.blueSlider else {
            return
        }
        
        var r:CGFloat = 0.0
        var g:CGFloat = 0.0
        var b:CGFloat = 0.0
        var a:CGFloat = 0.0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        redSlider.setValue(Float(r), animated: true)
        greenSlider.setValue(Float(g), animated: true)
        blueSlider.setValue(Float(b), animated: true)
    }
    
    private func setupColorView() {
        self.colorView?.backgroundColor = color
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let backgroundColor = self.colorView?.backgroundColor else { return }
        
        delegate?.configure(self, didPick: backgroundColor)
    }
    
    private func updateColorView() {
        guard let redSlider  = self.redSlider,
              let greenSlider = self.greenSlider,
              let blueSlider = self.blueSlider,
              let colorView  = self.colorView  else {
            return
        }
        
        let color = UIColor(red: CGFloat(redSlider.value),
                            green: CGFloat(greenSlider.value),
                            blue: CGFloat(blueSlider.value), alpha: 1.0)
        
        colorView.backgroundColor = color
    }
    
    @IBAction func colorDidChange(_ sender: UISlider) {
        updateColorView()
    }
}
