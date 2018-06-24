//
//  DashboardViewController.swift
//  Throughput Calculation
//
//  Created by Avinav Goel on 28/03/17.
//  Copyright © 2017 Avinav Goel. All rights reserved.
//

import UIKit
import Firebase
import DropDown

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case let (l?, r?):
		return l < r
	case (nil, _?):
		return true
	default:
		return false
	}
}


// A delay function
func delay(seconds: Double, completion:@escaping ()->()) {
	let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
	
	DispatchQueue.main.asyncAfter(deadline: popTime) {
		completion()
	}
}

class DashboardViewController: UIViewController, CAAnimationDelegate {
	
	// MARK: IB outlets
	
	@IBOutlet var goButton: UIButton!
	@IBOutlet var heading: UILabel!

	@IBOutlet weak var airportLabel: UILabel!
	@IBOutlet weak var carrierLabel: UILabel!
	@IBOutlet weak var flightNoLabel: UILabel!
	
	@IBOutlet weak var airportButton: UIButton!
	@IBOutlet weak var carrierButton: UIButton!
	@IBOutlet weak var flightNoButton: UIButton!
	
	let airportDropDown = DropDown()
	let carrierDropDown = DropDown()
	let flightNoDropDown = DropDown()
	
	lazy var dropDowns: [DropDown] = {
		return [
			self.airportDropDown,
			self.carrierDropDown,
			self.flightNoDropDown
		]
	}()
	
	var counters : [Counter]! = []
	var airports: [String:[String:[String]]] = [:]
	
	
	let defaults = UserDefaults.standard
	
	var ref:DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		//Set Up DropDowns
		airportDropDown.anchorView = airportButton
		carrierDropDown.anchorView = carrierButton
		flightNoDropDown.anchorView = flightNoButton
		
		airportDropDown.bottomOffset = CGPoint(x: 0, y:5)
		carrierDropDown.bottomOffset = CGPoint(x: 0, y:5)
		flightNoDropDown.bottomOffset = CGPoint(x: 0, y:5)
		
		airportDropDown.selectionAction = { [weak self] (index, item) in
			self?.airportButton.setTitle(item, for: .normal)
			if let carriers = self?.airports[item]{
				self?.carrierDropDown.dataSource =  Array(carriers.keys)
				self?.flightNoDropDown.dataSource = []
				self?.carrierButton.setTitle("", for: .normal)
				self?.flightNoButton.setTitle("", for: .normal)
			}
			self?.goButton.isEnabled = false
		}
		carrierDropDown.selectionAction = { [weak self] (index, item) in
			self?.carrierButton.setTitle(item, for: .normal)
			if let flights = self?.airports[(self?.airportButton.title(for: .normal))!]?[(self?.carrierButton.title(for: .normal)!)!]{
				self?.flightNoDropDown.dataSource = Array(flights)
				self?.flightNoButton.setTitle("", for: .normal)
			}
			self?.goButton.isEnabled = false
		}
		flightNoDropDown.selectionAction = { [weak self] (index, item) in
			self?.flightNoButton.setTitle(item, for: .normal)
			self?.goButton.isEnabled = true
		}
		
		dropDowns.forEach { $0.dismissMode = .onTap }
		dropDowns.forEach { $0.direction = .any }
		
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		
		self.goButton.isEnabled = false
		
		//		self.findCarriers()
//		FIRDatabase.database().persistenceEnabled = true
//		if !FIRDatabase.database().persistenceEnabled{
//			FIRDatabase.database().persistenceEnabled = true
//		}
		ref = Database.database().reference()
		findAirportsAndCarriers()
		
	}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	//MARK:- Dropdown Button Pressed
	
	@IBAction func aiportButtonPressed(_ sender: Any) {
		self.airportDropDown.show()
	}
	@IBAction func carrierButtonPressed(_ sender: Any) {
		self.carrierDropDown.show()
	}
	@IBAction func flightNoButtonPressed(_ sender: Any) {
		self.flightNoDropDown.show()
	}
	
	
	
	
	// MARK: further methods
	
	///Func to fetch details from the firebase
	func findAirportsAndCarriers(){
		
		self.ref.observeSingleEvent(of: .value, with: { (snapshot) in
			if let dict = snapshot.value as? [String:[String:[String:Any]]]{
				for airport in dict.keys{
					self.airports[airport] = [:]
//					self.airports = Map(Array(dict.keys),[])
//					var carriersArray : [String:[String]] = [:]
					if let carriers = dict[airport]{
//						carriersArray += Array(carriers.keys)
						for carrier in carriers.keys{
							self.airports[airport]?[carrier] = []
							if let flights = carriers[carrier]?["flight"] as? [String:Any]{
								self.airports[airport]?[carrier] = []
								for flight in flights.keys{
									self.airports[airport]?[carrier]?.append(flight)
								}
							}
						}
					}
					
					//TODO:- Get the flight No
				}
				
				
				if self.airportDropDown.dataSource.isEmpty{
					self.airportDropDown.dataSource = Array(self.airports.keys)
					self.fillDropDownAndUpdate()
				}
				else{
					self.airportDropDown.dataSource = Array(self.airports.keys)
				}
				
			}
		})
	}
	
	func fillDropDownAndUpdate(){
		self.airportButton.setTitle(self.airports.keys.first, for: .normal)
		if let carriers = self.airports[(self.airportButton.title(for: .normal))!]{
			self.carrierDropDown.dataSource =  Array(carriers.keys)
			self.flightNoDropDown.dataSource = []
			self.carrierButton.setTitle(carriers.keys.first, for: .normal)
			
		}
		if let flights = self.airports[(self.airportButton.title(for: .normal))!]?[(self.carrierButton.title(for: .normal)!)]{
			self.flightNoDropDown.dataSource = Array(flights)
			self.flightNoButton.setTitle(flights.first, for: .normal)
			self.goButton.isEnabled = true
		}
	}
	
	@IBAction func goButtonPressed() {
		
		//Navigation and Utilities
		self.counters = []
		self.performSegue(withIdentifier: "showTabBarController", sender: self)
	}

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		if segue.identifier == "showTabBarController"{
			if let tabVC = segue.destination as? CarrierTabBarController{
				//				tabVC.counters = self.counters
				tabVC.airportName = self.airportButton.title(for: .normal)!
				tabVC.carrierName = self.carrierButton.title(for: .normal)!
				tabVC.flightNo = self.flightNoButton.title(for: .normal)!
			}
		}
	}


}
