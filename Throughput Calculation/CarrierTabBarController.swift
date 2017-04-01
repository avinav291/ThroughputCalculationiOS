//
//  CarrierTabBarController.swift
//  Throughput Calculation
//
//  Created by Avinav Goel on 24/03/17.
//  Copyright © 2017 Avinav Goel. All rights reserved.
//

import UIKit

class CarrierTabBarController: UITabBarController {

//	var counters:[Counter]! = []
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	var airportName:String! = ""
	var carrierName:String! = ""
	var flightNo:String! = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
//		if let queueVC = self.childViewControllers[1] as? QueueDisplayViewController{
//			queueVC.counters = self.counters
//		}
		if let flightVC = self.childViewControllers[1] as? BoardingDetailsViewController{
			flightVC.airportName = airportName
			flightVC.carrierName = carrierName
			flightVC.flightNo = flightNo
		}

		
		if let queueVC = self.childViewControllers[2] as? AnimatedQueueDisplayViewController{
//			queueVC.counters = self.counters
			queueVC.airportName = self.airportName
			queueVC.carrierName = self.carrierName
		}
		
		if let mapVC = self.childViewControllers[0] as? MapViewController{
			mapVC.airportName = airportName
			mapVC.carrierName = carrierName
			mapVC.flightNo = flightNo
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
