//
//  DetalhesViewController.swift
//  Analisar Flores
//
//  Created by Wanderson Hipolito on 19/11/20.
//

import UIKit

class DetalhesViewController: UIViewController {

    
    
    @IBOutlet weak var showDetailsLabel: UILabel!
    
    var destailsText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.showDetailsLabel.text = destailsText
        print(destailsText!)
        
    }


}
