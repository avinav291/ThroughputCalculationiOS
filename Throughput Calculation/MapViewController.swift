//
//  ViewController.swift
//  Throughput Calculation
//
//  Created by Avinav Goel on 22/03/17.
//  Copyright © 2017 Avinav Goel. All rights reserved.
//

import UIKit
import Firebase

enum TravelModes: Int {
	case driving
	case walking
	case bicycling
}

class MapViewController: UIViewController {

	@IBOutlet weak var viewMap: GMSMapView!
	@IBOutlet weak var bottomCardView: MKCardView!
	@IBOutlet weak var statusBannerIV: UIImageView!
	
	@IBOutlet weak var bbFindAddress: UIBarButtonItem!
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	
	var locationMarker: GMSMarker!
	
//	//Flight Label Markers
//	@IBOutlet weak var sourceLabel: UILabel!
//	@IBOutlet weak var destinationLabel: UILabel!
//	@IBOutlet weak var departureTimeLabel: UILabel!
//	@IBOutlet weak var arrivalTimeLabel: UILabel!
//	@IBOutlet weak var boardingGateLabel: UILabel!
	
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	
	
	//Core Location Params
	var locationManager = CLLocationManager()
 
	var didFindMyLocation = false
	
	var originMarker: GMSMarker!
 
	var destinationMarker: GMSMarker!
 
	var routePolyline: GMSPolyline!
	
	var airportName:String!
	var carrierName:String!
	var flightNo:String!
	
	//Travel Modes
	var travelMode = TravelModes.driving
	
	var ref = Database.database().reference()
	
	//Minimum Average Time
	var minAvgTime:Double = 0.0
	var minCounter:Int = 0
	
	var isStatusDistanceBased = true
	
	var arrivalTime:Date! = Date()
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		
		self.viewMap.padding = UIEdgeInsets(top: self.statusBannerIV.center.y+self.statusBannerIV.bounds.height, left: 0, bottom: self.bottomCardView.bounds.height+10, right: 0)
		
		self.viewMap.layer.cornerRadius = 1
		self.viewMap.layer.shadowOpacity = 1
		self.viewMap.layer.shadowRadius = 2
		self.viewMap.layer.shadowOffset = CGSize(width: 1, height: 1)
		self.viewMap.layer.shadowColor = UIColor.gray.cgColor
		self.viewMap.layer.masksToBounds = false
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.getFlightDetails()
		self.getSmallestThroughputDetails()
		
		// Do any additional setup after loading the view, typically from a nib.
		let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 25.435801, longitude: 81.846311, zoom: 8.0)
		viewMap.camera = camera
		self.locationManager.delegate = self
//		DispatchQueue.main.async {
			self.locationManager.requestWhenInUseAuthorization()
			self.locationManager.startUpdatingHeading()
			self.viewMap.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
//		}
		viewMap.delegate = self
	}
	
	deinit {
		viewMap.removeObserver(self, forKeyPath: "myLocation", context: nil)
		locationManager.delegate = nil
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK:- get flight Details
	func getFlightDetails(){
		
		ref.child("\(self.airportName!)/\(self.carrierName!)/flight/\(self.flightNo!)").observe(.value, with: { (snapshot) in
			if let snap = snapshot.value as? [String:Any]{
				
//				let dateFormatter = DateFormatter()
//				dateFormatter.timeStyle = .medium
//				dateFormatter.dateStyle = .long
//				
//				let timeInterval = TimeInterval(Double(snap["arrivalTime"] as! String)!/1000.0)
//				let timeInterval = (snap["arrivalTime"] as! TimeInterval)
//				let date = Date(timeIntervalSince1970: TimeInterval(Double(snap["arrivalTime"] as! String)!/1000.0))
				
				self.arrivalTime = Date(timeIntervalSince1970: TimeInterval(Double(snap["departureTime"] as! String)!/1000.0))
				
				self.displayRouteInfo()
//				self.sourceLabel.text = snap["source"] as? String
//				self.destinationLabel.text = snap["destination"] as? String
//				self.arrivalTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(Double(snap["arrivalTime"] as! String)!/1000.0)))
//				self.departureTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(Double(snap["departureTime"] as! String)!/1000.0)))
//				self.boardingGateLabel.text = snap["boardingGate"] as? String
			}
		})
	}
	
	func getSmallestThroughputDetails(){
		ref.child("\(self.airportName!)/\(self.carrierName!)/carrier").observe(.value, with: { (snapshot) in
			//			print(snapshot.value!)
			if let snap = snapshot.value as? NSArray{
				//				print(snap)
				self.minAvgTime = Double.infinity
				for lane in snap{
					if let counter = lane as? [String:Any]{
						let counterTime:Double = Double(counter["avgWaitingTime"] as! String)!
						if self.minAvgTime > counterTime{
							self.minAvgTime = counterTime
							self.minCounter = Int(counter["counterNumber"] as! String)!
						}
					}
				}
				self.displayRouteInfo()
			}
		})
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if !didFindMyLocation {
			let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
			self.locationManager.stopUpdatingLocation()
			viewMap.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
			viewMap.settings.myLocationButton = true
			
			didFindMyLocation = true
			let origin = "\(myLocation.coordinate.latitude),\(myLocation.coordinate.longitude)"
			self.createRouteToAirport(origin: origin)
		}
	}

	
	func createRouteToAirport(origin:String!){
		
		DispatchQueue.main.async {
			if self.airportName != nil{
				if (self.routePolyline) != nil {
					self.clearRoute()
				}
				
				let destination = self.airportName
				
				self.self.appDelegate.mapTasks.getDirections(origin: origin, destination: destination, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
					if success {
						self.configureMapAndMarkersForRoute()
						self.drawRoute()
						self.displayRouteInfo()
					}
					else {
						print(status)
					}
				})
			}
		}
		
	}
	
	// MARK: IBAction method implementation
	
	@IBAction func changeMapType(sender: AnyObject) {
		let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: UIAlertControllerStyle.actionSheet)
		
		let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.default) { (alertAction) -> Void in
			self.viewMap.mapType = .normal
			self.recreateRoute()
		}
		
		let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.default) { (alertAction) -> Void in
			self.viewMap.mapType = .terrain
			self.recreateRoute()
		}
		
		let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.default) { (alertAction) -> Void in
			self.viewMap.mapType = .hybrid
			self.recreateRoute()
		}
		
		let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
			
		}
		
		actionSheet.addAction(normalMapTypeAction)
		actionSheet.addAction(terrainMapTypeAction)
		actionSheet.addAction(hybridMapTypeAction)
		actionSheet.addAction(cancelAction)
		
		present(actionSheet, animated: true, completion: nil)
		
	}
	
	func setupLocationMarker(coordinate: CLLocationCoordinate2D) {
		
		if locationMarker != nil {
			locationMarker.map = nil
		}
		
		locationMarker = GMSMarker(position: coordinate)
		locationMarker.map = viewMap
		locationMarker.title = self.appDelegate.mapTasks.fetchedFormattedAddress
		locationMarker.appearAnimation = .pop
		locationMarker.icon = GMSMarker.markerImage(with: UIColor.blue)
		locationMarker.opacity = 0.75
	}
	
	@IBAction func findAddress(sender: AnyObject) {
		
		self.clearRoute()
		
		let addressAlert = UIAlertController(title: "Address Finder", message: "Type the address you want to find:", preferredStyle: UIAlertControllerStyle.alert)
		
		addressAlert.addTextField { (textField) -> Void in
			textField.placeholder = "Address?"
		}
		
		let findAction = UIAlertAction(title: "Find Address", style: UIAlertActionStyle.default) { (alertAction) -> Void in
			let address = (addressAlert.textFields![0] as UITextField).text! as String
			
			self.createRouteToAirport(origin: address)
//			self.appDelegate.mapTasks.geocodeAddress(address: address, withCompletionHandler: { (status, success) -> Void in
//				if !success {
//					print(status)
//					
//					if status == "ZERO_RESULTS" {
//						self.showAlertWithMessage(message: "The location could not be found.")
//					}
//				}
//				else {
//					let coordinate = CLLocationCoordinate2D(latitude: self.appDelegate.mapTasks.fetchedAddressLatitude, longitude: self.appDelegate.mapTasks.fetchedAddressLongitude)
//					self.viewMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 14.0)
//					self.setupLocationMarker(coordinate: coordinate)
//				}
//			})
			
		}
		
		let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
			
		}
		
		addressAlert.addAction(findAction)
		addressAlert.addAction(closeAction)
		
		present(addressAlert, animated: true, completion: nil)
	}
	
	func showAlertWithMessage(message: String) {
		let alertController = UIAlertController(title: "Maps Issue", message: message, preferredStyle: UIAlertControllerStyle.alert)
		
		let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
			
		}
		
		alertController.addAction(closeAction)
		
		present(alertController, animated: true, completion: nil)
	}
	
	
	@IBAction func createRoute(sender: AnyObject) {
		let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.alert)
		
		addressAlert.addTextField { (textField) -> Void in
			textField.placeholder = "Origin?"
		}
		
		addressAlert.addTextField { (textField) -> Void in
			textField.placeholder = "Destination?"
		}
		
		let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.default) { (alertAction) -> Void in
			if (self.routePolyline) != nil {
				self.clearRoute()
			}
			
			let origin = (addressAlert.textFields![0] as UITextField).text! as String
			let destination = (addressAlert.textFields![1] as UITextField).text! as String
			
			self.self.appDelegate.mapTasks.getDirections(origin: origin, destination: destination, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
				if success {
					self.configureMapAndMarkersForRoute()
					self.drawRoute()
					self.displayRouteInfo()
				}
				else {
					print(status)
				}
			})
		}
		
		let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
			
		}
		
		addressAlert.addAction(createRouteAction)
		addressAlert.addAction(closeAction)
		
		present(addressAlert, animated: true, completion: nil)
	}
	
	func configureMapAndMarkersForRoute() {
		viewMap.camera = GMSCameraPosition.camera(withTarget: self.appDelegate.mapTasks.originCoordinate, zoom: 9.0)
		
		
		originMarker = GMSMarker(position: self.self.appDelegate.mapTasks.originCoordinate)
		originMarker.map = self.viewMap
		originMarker.icon = GMSMarker.markerImage(with: UIColor.green)
		originMarker.title = self.self.appDelegate.mapTasks.originAddress
		
		destinationMarker = GMSMarker(position: self.self.appDelegate.mapTasks.destinationCoordinate)
		destinationMarker.map = self.viewMap
		destinationMarker.icon = GMSMarker.markerImage(with: UIColor.red)
		destinationMarker.title = self.self.appDelegate.mapTasks.destinationAddress
	}
	
	func drawRoute() {
		let route = self.appDelegate.mapTasks.overviewPolyline["points"] as! String
		
		let path: GMSPath = GMSPath(fromEncodedPath: route)!
		routePolyline = GMSPolyline(path: path)
		routePolyline.map = viewMap
		
		let coordibateBounds = GMSCoordinateBounds(path: path)
		self.viewMap.animate(with: GMSCameraUpdate.fit(coordibateBounds, withPadding: 10.0))
	}
	
	func displayRouteInfo() {
		
		self.distanceLabel.text = "\(self.appDelegate.mapTasks.totalDistanceInMeters/1000) km"
		
		if self.appDelegate.mapTasks.totalDistanceInMeters<100{
			self.isStatusDistanceBased = false
		}
		else{
			self.isStatusDistanceBased = true
		}
		
//			+ "\n" + self.appDelegate.mapTasks.totalDuration
		let totalTime = self.appDelegate.mapTasks.totalDurationInSeconds + UInt(self.minAvgTime*60) + UInt(45*60)
		let mins = totalTime / 60
		let hours = mins / 60
		let days = hours / 24
		let remainingHours = hours % 24
		let remainingMins = mins % 60
		let remainingSecs = totalTime % 60
		
		if self.isStatusDistanceBased{
			let timeInterval = self.arrivalTime.timeIntervalSince1970 - Double(totalTime)
			let dateToLeave = Date(timeIntervalSince1970: timeInterval)
//			let dateToLeave = Date(timeIntervalSinceNow: TimeInterval(totalTime))
			let formatter = DateFormatter()
			formatter.dateStyle = .none
			formatter.timeStyle = .short
			
			self.statusLabel.text = "Leave before \(formatter.string(from: dateToLeave))"
		}
		else{
			self.statusLabel.text = "Move to Counter \(self.minCounter)"
		}
		
		var totalDuration = ""
		if days > 0{
			totalDuration.append("\(days) d ")
		}
		if remainingHours > 0{
			totalDuration.append("\(remainingHours) h ")
		}
		if remainingMins > 0{
			totalDuration.append("\(remainingMins) m ")
		}
		
//		let totalDuration = "\(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
		
		self.timeLabel.text = totalDuration
	}
	
	func clearRoute() {
		
		if originMarker != nil{
			originMarker.map = nil
		}
		if destinationMarker != nil{
			destinationMarker.map = nil
		}
		if routePolyline != nil{
			routePolyline.map = nil
		}

	}
	
	func recreateRoute() {
		if (routePolyline) != nil {
			clearRoute()
			
			self.appDelegate.mapTasks.getDirections(origin: self.appDelegate.mapTasks.originAddress, destination: self.appDelegate.mapTasks.destinationAddress, waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
				
				if success {
					self.configureMapAndMarkersForRoute()
					self.drawRoute()
					self.displayRouteInfo()
				}
				else {
					print(status)
				}
			})
		}
	}
	
	//MARK:- Travelling Modes
	@IBAction func changeTravelMode(sender: AnyObject) {
		let actionSheet = UIAlertController(title: "Travel Mode", message: "Select travel mode:", preferredStyle: UIAlertControllerStyle.actionSheet)
		
		let drivingModeAction = UIAlertAction(title: "Driving", style: UIAlertActionStyle.default) { (alertAction) -> Void in
			self.travelMode = TravelModes.driving
			self.recreateRoute()
		}
		
		let walkingModeAction = UIAlertAction(title: "Walking", style: UIAlertActionStyle.default) { (alertAction) -> Void in
			self.travelMode = TravelModes.walking
			self.recreateRoute()
		}
		
		let bicyclingModeAction = UIAlertAction(title: "Bicycling", style: UIAlertActionStyle.default) { (alertAction) -> Void in
			self.travelMode = TravelModes.bicycling
			self.recreateRoute()
		}
		
		let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
			
		}
		
		actionSheet.addAction(drivingModeAction)
		actionSheet.addAction(walkingModeAction)
		actionSheet.addAction(bicyclingModeAction)
		actionSheet.addAction(closeAction)
		
		present(actionSheet, animated: true, completion: nil)
	}


}

//MARK:- Location Manager Delegate

extension MapViewController:CLLocationManagerDelegate, GMSMapViewDelegate{
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.authorizedWhenInUse {
			viewMap.isMyLocationEnabled = true
		}
	}
	
	func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
		
		if mapView.myLocation != nil{
			let origin = "\(mapView.myLocation!.coordinate.latitude),\(mapView.myLocation!.coordinate.longitude)"
			self.createRouteToAirport(origin: origin)
		}
		return true
	}
	
	
	
}
