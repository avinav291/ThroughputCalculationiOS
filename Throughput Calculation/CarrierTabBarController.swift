//
//  CarrierTabBarController.swift
//  Throughput Calculation
//
//  Created by Avinav Goel on 24/03/17.
//  Copyright © 2017 Avinav Goel. All rights reserved.
//

import UIKit

class CarrierTabBarController: UITabBarController {

	var counters:[Counter]! = []
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		if let queueVC = self.childViewControllers[1] as? QueueDisplayViewController{
			queueVC.counters = self.counters
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
