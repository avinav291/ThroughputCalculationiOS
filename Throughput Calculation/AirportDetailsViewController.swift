//
//  AirportDetailsViewController.swift
//  Throughput Calculation
//
//  Created by Avinav Goel on 24/03/17.
//  Copyright © 2017 Avinav Goel. All rights reserved.
//

import UIKit

class AirportDetailsViewController: UIViewController {

	@IBOutlet weak var airportNameTF: MKTextField!
	@IBOutlet weak var carrierNameTF: MKTextField!
	
	var counters : [Counter]! = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func goButtonPressed(_ sender: Any) {
		
		self.getDetails()
		
	}
	
	
	func getDetails(){
		let airportName = self.airportNameTF.text
		let carrierName = self.carrierNameTF.text
		
		if airportName != "" && carrierName != ""{
		
			let url = URL(string: "http://localhost:3000/api/sendQueueData")
			let postString = "airportName=\(airportName!)&carrierName=\(carrierName!)"
			let request = NSMutableURLRequest(url: url!)
			request.httpMethod = "POST"
			request.httpBody = postString.data(using: .utf8)
			
			let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
				if error != nil {
					print(error!)
					return
				}
				do{

					let responseJson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String:Any]]
					print(responseJson)
					
					for counter in responseJson{
						self.counters.append(Counter(throughput: counter["throughput"] as! Int, counterNumber: counter["counterNumber"] as! Int, counterCount: counter["counterCount"] as! Int))
					}
					
					self.performSegue(withIdentifier: "showTabBarController", sender: self)
					
					
				}
				catch{
					print("Json Receiving error")
				}
			})
			
			task.resume()
		}
	}
	

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		if segue.identifier == "showTabBarController"{
			if let tabVC = segue.destination as? CarrierTabBarController{
				tabVC.counters = self.counters
			}
		}
    }


}
