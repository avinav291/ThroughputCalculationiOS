//
//  ViewController.swift
//  Throughput Calculation
//
//  Created by Avinav Goel on 22/03/17.
//  Copyright © 2017 Avinav Goel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var viewMap: GMSMapView!
	
	@IBOutlet weak var bbFindAddress: UIBarButtonItem!
	
	@IBOutlet weak var lblInfo: UILabel!
	
	//Core Location Params
	var locationManager = CLLocationManager()
 
	var didFindMyLocation = false
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 48.857165, longitude: 2.354613, zoom: 8.0)
		viewMap.camera = camera
		
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		
		viewMap.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if !didFindMyLocation {
			let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
			viewMap.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
			viewMap.settings.myLocationButton = true
			
			didFindMyLocation = true
		}
	}

	
	// MARK: IBAction method implementation
	
	@IBAction func changeMapType(sender: AnyObject) {
		let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: UIAlertControllerStyle.actionSheet)
		
		let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.default) { (alertAction) -> Void in
			self.viewMap.mapType = .normal
		}
		
		let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.default) { (alertAction) -> Void in
			self.viewMap.mapType = .terrain
		}
		
		let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.default) { (alertAction) -> Void in
			self.viewMap.mapType = .hybrid
		}
		
		let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
			
		}
		
		actionSheet.addAction(normalMapTypeAction)
		actionSheet.addAction(terrainMapTypeAction)
		actionSheet.addAction(hybridMapTypeAction)
		actionSheet.addAction(cancelAction)
		
		present(actionSheet, animated: true, completion: nil)
		
	}
	
	
	@IBAction func findAddress(sender: AnyObject) {
		
	}
	
	
	@IBAction func createRoute(sender: AnyObject) {
		
	}
	
	
	@IBAction func changeTravelMode(sender: AnyObject) {
		
	}


}

//MARK:- Location Manager Delegate

extension ViewController:CLLocationManagerDelegate{
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.authorizedWhenInUse {
			viewMap.isMyLocationEnabled = true
		}
	}
	
}








