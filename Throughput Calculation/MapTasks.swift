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
	
	let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
 
	var selectedRoute: [String:Any]!
 
	var overviewPolyline: [String:Any]!
 
	var originCoordinate: CLLocationCoordinate2D!
 
	var destinationCoordinate: CLLocationCoordinate2D!
 
	var originAddress: String!
 
	var destinationAddress: String!
	
	var totalDistanceInMeters: UInt = UInt.max
 
	var totalDistance: String!
 
	var totalDurationInSeconds: UInt = 0
 
	var totalDuration: String!
	
	override init() {
		super.init()
	}
	
	//MARK:- GEOCODING
	
	func geocodeAddress(address: String!, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
		if let lookupAddress = address {
			var geocodeURLString = baseURLGeocode+"key=AIzaSyB3_9SBQ6km_XsjBwIAblBMhVslognXNdY&" + "address=" + lookupAddress
			geocodeURLString = geocodeURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
			
			DispatchQueue.main.async {
				let geocodingResultsData = try? Data(contentsOf: URL(string: geocodeURLString)!)
				
				do{
					let dictionary = try JSONSerialization.jsonObject(with: geocodingResultsData! as Data, options: .mutableContainers) as! [String:Any]
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
	
	//MARK:- Direction routing
	
	func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: TravelModes!, completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
		if let originLocation = origin {
			if let destinationLocation = destination {
				var directionsURLString = baseURLDirections + "key=AIzaSyB3_9SBQ6km_XsjBwIAblBMhVslognXNdY&" + "origin=" + originLocation + "&destination=" + destinationLocation
				
				if (travelMode) != nil {
					var travelModeString = ""
					
					switch travelMode.rawValue {
					case TravelModes.walking.rawValue:
						travelModeString = "walking"
						
					case TravelModes.bicycling.rawValue:
						travelModeString = "bicycling"
						
					default:
						travelModeString = "driving"
					}
					directionsURLString += "&mode=" + travelModeString
				}
				directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
				let directionsURL = NSURL(string: directionsURLString)
				
				DispatchQueue.main.async {
					
					guard let directionsData = NSData(contentsOf: directionsURL! as URL) else{
						return
					}
					
					do{
						if let dictionary = try JSONSerialization.jsonObject(with: directionsData as Data, options: .mutableContainers) as? [String:Any] {
							let status = dictionary["status"] as! String
							
							if status == "OK" {
								self.selectedRoute = (dictionary["routes"] as! [[String:Any]])[0]
								self.overviewPolyline = self.selectedRoute["overview_polyline"] as! [String:Any]
								
								let legs = self.selectedRoute["legs"] as! [[String:Any]]
								
								let startLocationDictionary = legs[0]["start_location"] as! [String:Any]
								self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
								
								let endLocationDictionary = legs[legs.count - 1]["end_location"] as! [String:Any]
								self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
								
								self.originAddress = legs[0]["start_address"] as! String
								self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
								
								self.calculateTotalDistanceAndDuration()
								
								completionHandler(status, true)
							}
							else {
								completionHandler(status, false)
							}
						}
						
					}
					catch{
						completionHandler("NOT OK", false)
					}
					
					
				}
			}
			else {
				completionHandler("Destination is nil.", false)
			}
		}
		else {
			completionHandler("Origin is nil", false)
		}
	}
	
	func calculateTotalDistanceAndDuration() {
		let legs = self.selectedRoute["legs"] as! [[String:Any]]
		
		totalDistanceInMeters = 0
		totalDurationInSeconds = 0
		
//		for leg in legs {
		totalDistanceInMeters = (legs[0]["distance"] as! [String:Any])["value"] as! UInt
		totalDurationInSeconds = (legs[0]["duration"] as! [String:Any])["value"] as! UInt
		
		
		let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
		totalDistance = "Total Distance: \(distanceInKilometers) Km"
		
		
		let mins = totalDurationInSeconds / 60
		let hours = mins / 60
		let days = hours / 24
		let remainingHours = hours % 24
		let remainingMins = mins % 60
		let remainingSecs = totalDurationInSeconds % 60
		
		totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
	}
	
}


