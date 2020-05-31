//
//  GuideViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 23.05.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {


    @IBAction func Close_popupView(_ sender: Any) {
        removeAnimate()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
            showAnimate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {

            self.removeAnimate()
            
              }
        
        }
    
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }

    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
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
}
