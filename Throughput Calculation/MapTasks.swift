//
//  MapTasks.swift
//  Throughput Calculation
//
//  Created by Avinav Goel on 23/03/17.
//  Copyright © 2017 Avinav Goel. All rights reserved.
//

import UIKit

class MapTasks: NSObject {

	let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
 
	var lookupAddressResults: [String:Any] = [:]
 
	var fetchedFormattedAddress: String!
 
	var fetchedAddressLongitude: Double!
 
	var fetchedAddressLatitude: Double!
	
	override init() {
		super.init()
	}
	
	func geocodeAddress(address: String!, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
		if let lookupAddress = address {
			var geocodeURLString = baseURLGeocode + "address=" + lookupAddress
			geocodeURLString = geocodeURLString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
			
			let geocodeURL = NSURL(string: geocodeURLString)
			
			DispatchQueue.main.async {
				let geocodingResultsData = try? Data(contentsOf: geocodeURL! as URL)
				
				do{
					let dictionary = try JSONSerialization.jsonObject(with: geocodingResultsData!, options: .mutableContainers) as! [String:Any]
					
					let status = dictionary["status"] as! String
					
					if status == "OK" {
						let allResults = dictionary["results"] as! [[String:Any]]
						self.lookupAddressResults = allResults[0]
						
						// Keep the most important values.
						self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String
						let geometry = self.lookupAddressResults["geometry"] as! [String:Any]
						self.fetchedAddressLongitude = ((geometry["location"] as! [String:Any])["lng"] as! NSNumber).doubleValue
						self.fetchedAddressLatitude = ((geometry["location"] as! [String:Any])["lat"] as! NSNumber).doubleValue
						
						completionHandler(status, true)
					}
					else {
						completionHandler(status, false)
					}
				}
				catch{
					print("error in JSon Serialization")
				}
			}
		}
		else{
			completionHandler("No valid address.", false)
		}
	}
}
