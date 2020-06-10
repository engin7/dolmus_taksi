//
//  RatingsViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 9.06.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit

class RatingsViewController: UIViewController {

    
    @IBOutlet var starButtons: [UIButton]!
    
    @IBAction func starButtonPressed(_ sender: UIButton) {
        
        let tag = sender.tag
        for button in starButtons {
            
            if button.tag <= tag {
                button.setTitle("★", for: .normal)
            } else {
                button.setTitle("☆", for: .normal)
            }
        }
        
        removeAnimate()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func removeAnimate()
       {
           UIView.animate(withDuration: 0.8, animations: {
               self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
               self.view.alpha = 0.0
           }, completion: {(finished : Bool) in
               if(finished)
               {
                   self.willMove(toParent: nil)
                   self.view.removeFromSuperview()
                   self.removeFromParent()
               }
           })
       }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
