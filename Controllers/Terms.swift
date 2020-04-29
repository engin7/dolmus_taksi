//
//  Terms.swift
//  Taxiz
//
//  Created by Engin KUK on 29.04.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit

class Terms: UIViewController {

    
    @IBAction func termsOK(_ sender: Any) {
        
        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "tabs") as? UITabBarController

        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
       
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

 
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
