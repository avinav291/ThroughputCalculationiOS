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
	@IBOutlet weak var ipAddressTF: MKTextField!
	
	var counters : [Counter]! = []
	var airports: [String:[String]] = [:]

	var airportPickerView  = UIPickerView()
	var carrierPickerView  = UIPickerView()
	
	let defaults = UserDefaults.standard
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		self.airportNameTF.text = ""
		self.carrierNameTF.text = ""
//		self.findCarriers()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		airportPickerView.delegate = self
		airportPickerView.dataSource = self
		
		carrierPickerView.delegate = self
		carrierPickerView.dataSource = self
		
		self.airportNameTF.inputView = airportPickerView
		self.carrierNameTF.inputView = carrierPickerView
		
        // Do any additional setup after loading the view.
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func goButtonPressed(_ sender: Any) {
		self.counters = []
		self.getDetails()
		
	}
	
	@IBAction func IPActionButtonPressed(_ sender: Any) {
		let ipAddress  = self.ipAddressTF.text ?? "localhost:3000"
		
		defaults.set(ipAddress, forKey: "ipAddress")
		self.findCarriers()
	}
	func findCarriers(){
		
		
		let ipAddress = self.defaults.string(forKey: "ipAddress")
		let url = URL(string: "http://\(ipAddress!)/api/sendCarriers")
		let request = NSMutableURLRequest(url: url!)
		request.httpMethod = "GET"
		
		let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
			if error != nil {
				print(error!)
				return
			}
			do{
				
				let responseJson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
				print(responseJson)
				
				if let json = responseJson as? [String:[String]]{
					self.airports = json
					self.airportPickerView.reloadAllComponents()
					self.carrierPickerView.reloadAllComponents()
				}
				
				
			}
			catch{
				print("Json Receiving error")
			}
		})
		
		task.resume()
	}
	
	
	func getDetails(){
		let airportName = self.airportNameTF.text
		let carrierName = self.carrierNameTF.text
		
		if airportName != "" && carrierName != ""{
			
			let ipAddress = defaults.string(forKey: "ipAddress")
			
			let url = URL(string: "http://\(ipAddress!)/api/sendQueueData")
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

					let responseJson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
					
					if let json = responseJson as? [[String:Any]]{
						
						for counter in json{
							self.counters.append(Counter(throughput: counter["throughput"] as! Int, counterNumber: counter["counterNumber"] as! Int, counterCount: counter["counterCount"] as! Int))
						}
						DispatchQueue.main.async {
							self.performSegue(withIdentifier: "showTabBarController", sender: self)
						}
					}
					
					
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
				tabVC.airportName = self.airportNameTF.text
				tabVC.carrierName = self.carrierNameTF.text
			}
		}
    }


}

extension AirportDetailsViewController:UIPickerViewDelegate, UIPickerViewDataSource{
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		if pickerView == self.airportPickerView{
			return self.airports.keys.count
		}
		else if pickerView == self.carrierPickerView{
			if let carriers = self.airports[self.airportNameTF.text!]{
				return carriers.count
			}
			else{
				return 0
			}
		}
		return 0
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView == self.airportPickerView{
			return Array(self.airports.keys)[row]
		}
		else if pickerView == self.carrierPickerView{
			if let carriers = self.airports[self.airportNameTF.text!]{
				return Array(carriers)[row]
			}
			else{
				return "Please Select an Airport"
			}
		}
		return ""
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView == self.airportPickerView{
			if self.airports.keys.count>0{
				self.airportNameTF.text = Array(self.airports.keys)[row]
			}
		}
		else if pickerView == self.carrierPickerView{
			if let carriers = self.airports[self.airportNameTF.text!]{
				self.carrierNameTF.text = Array(carriers)[row]
			}
			else{
				self.carrierNameTF.text = ""
			}
		}
		self.view.endEditing(true)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		view.endEditing(true)
	}
}
