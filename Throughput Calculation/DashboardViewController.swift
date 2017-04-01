//
//  DashboardViewController.swift
//  Throughput Calculation
//
//  Created by Avinav Goel on 28/03/17.
//  Copyright © 2017 Avinav Goel. All rights reserved.
//

import UIKit
import Firebase

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
	@IBOutlet var airportNameTF: UITextField!
	@IBOutlet var carrierNameTF: UITextField!
	@IBOutlet var flightNoTF: UITextField!
	
	var counters : [Counter]! = []
	var airports: [String:[String:[String]]] = [:]
	
	var airportPickerView  = UIPickerView()
	var carrierPickerView  = UIPickerView()
	var flightNoPickerView  = UIPickerView()
	
	let defaults = UserDefaults.standard
	
	var ref:FIRDatabaseReference!
	
	@IBOutlet var cloud1: UIImageView!
	@IBOutlet var cloud2: UIImageView!
	@IBOutlet var cloud3: UIImageView!
	@IBOutlet var cloud4: UIImageView!
	
	// MARK: further UI
	
//	let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
//	let status = UIImageView(image: UIImage(named: "banner"))
//	let label = UILabel()
//	let messages = ["Connecting ...", "Authorizing ...", "Sending credentials ...", "Failed"]
	
//	var statusPosition = CGPoint.zero
	
	let info = UILabel()
	
	convenience init() {
		self.init()
//		FIRDatabase.database().persistenceEnabled = true
//		ref = FIRDatabase.database().reference()
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		//Set Up the Text Fields
		airportPickerView.delegate = self
		airportPickerView.dataSource = self
		
		carrierPickerView.delegate = self
		carrierPickerView.dataSource = self
		
		flightNoPickerView.dataSource = self
		flightNoPickerView.delegate = self
		
		self.airportNameTF.inputView = airportPickerView
		self.carrierNameTF.inputView = carrierPickerView
		self.flightNoTF.inputView = flightNoPickerView
		
		//set up the UI
		goButton.layer.cornerRadius = 8.0
		goButton.layer.masksToBounds = true
		
		info.frame = CGRect(x: 0.0, y: goButton.center.y + 60.0,
		                    width: view.frame.size.width, height: 30)
		info.backgroundColor = UIColor.clear
		info.font = UIFont(name: "HelveticaNeue", size: 12.0)
		info.textAlignment = .center
		info.textColor = UIColor.white
		info.text = "Tap to select your Airport, Carrier and corresponding flight"
		view.insertSubview(info, belowSubview: goButton)
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		
		self.goButton.isEnabled = false
		self.airportNameTF.text = ""
		self.carrierNameTF.text = ""
		self.flightNoTF.text = ""
		//		self.findCarriers()
//		FIRDatabase.database().persistenceEnabled = true
		if !FIRDatabase.database().persistenceEnabled{
			FIRDatabase.database().persistenceEnabled = true
		}
		ref = FIRDatabase.database().reference()
		findAirportsAndCarriers()
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let formGroup = CAAnimationGroup()
		formGroup.duration = 0.5
		formGroup.fillMode = kCAFillModeBackwards
		
		let flyRight = CABasicAnimation(keyPath: "position.x")
		flyRight.fromValue = -view.bounds.size.width/2
		flyRight.toValue = view.bounds.size.width/2
		
		let fadeFieldIn = CABasicAnimation(keyPath: "opacity")
		fadeFieldIn.fromValue = 0.25
		fadeFieldIn.toValue = 1.0
		
		formGroup.animations = [flyRight, fadeFieldIn]
		heading.layer.add(formGroup, forKey: nil)
		
		formGroup.delegate = self
		formGroup.setValue("form", forKey: "name")
		formGroup.setValue(airportNameTF.layer, forKey: "layer")
		
		formGroup.beginTime = CACurrentMediaTime() + 0.3
		airportNameTF.layer.add(formGroup, forKey: nil)
		
		formGroup.setValue(carrierNameTF.layer, forKey: "layer")
		formGroup.beginTime = CACurrentMediaTime() + 0.4
		carrierNameTF.layer.add(formGroup, forKey: nil)
		
		formGroup.setValue(flightNoTF.layer, forKey: "layer")
		formGroup.beginTime = CACurrentMediaTime() + 0.5
		carrierNameTF.layer.add(formGroup, forKey: nil)
		
		let fadeIn = CABasicAnimation(keyPath: "opacity")
		fadeIn.fromValue = 0.0
		fadeIn.toValue = 1.0
		fadeIn.duration = 0.5
		fadeIn.fillMode = kCAFillModeBackwards
		fadeIn.beginTime = CACurrentMediaTime() + 0.5
		cloud1.layer.add(fadeIn, forKey: nil)
		
		fadeIn.beginTime = CACurrentMediaTime() + 0.7
		cloud2.layer.add(fadeIn, forKey: nil)
		
		fadeIn.beginTime = CACurrentMediaTime() + 0.9
		cloud3.layer.add(fadeIn, forKey: nil)
		
		fadeIn.beginTime = CACurrentMediaTime() + 1.1
		cloud4.layer.add(fadeIn, forKey: nil)
		
		let groupAnimation = CAAnimationGroup()
		groupAnimation.beginTime = CACurrentMediaTime() + 0.5
		groupAnimation.duration = 0.5
		groupAnimation.fillMode = kCAFillModeBackwards
		groupAnimation.timingFunction = CAMediaTimingFunction(
			name: kCAMediaTimingFunctionEaseIn)
		
		let scaleDown = CABasicAnimation(keyPath: "transform.scale")
		scaleDown.fromValue = 3.5
		scaleDown.toValue = 1.0
		
		let rotate = CABasicAnimation(keyPath: "transform.rotation")
		rotate.fromValue = CGFloat(M_PI_4)
		rotate.toValue = 0.0
		
		let fade = CABasicAnimation(keyPath: "opacity")
		fade.fromValue = 0.0
		fade.toValue = 1.0
		
		groupAnimation.animations = [scaleDown, rotate, fade]
		goButton.layer.add(groupAnimation, forKey: nil)
		
		animateCloud(cloud1.layer)
		animateCloud(cloud2.layer)
		animateCloud(cloud3.layer)
		animateCloud(cloud4.layer)
		
		let flyLeft = CABasicAnimation(keyPath: "position.x")
		flyLeft.fromValue = info.layer.position.x + view.frame.size.width
		flyLeft.toValue = info.layer.position.x
		flyLeft.duration = 5.0
		info.layer.add(flyLeft, forKey: "infoappear")
		
		let fadeLabelIn = CABasicAnimation(keyPath: "opacity")
		fadeLabelIn.fromValue = 0.2
		fadeLabelIn.toValue = 1.0
		fadeLabelIn.duration = 4.5
		info.layer.add(fadeLabelIn, forKey: "fadein")
		
		airportNameTF.delegate = self
		carrierNameTF.delegate = self
		flightNoTF.delegate = self
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
				self.airportPickerView.reloadAllComponents()
				self.carrierPickerView.reloadAllComponents()
				self.flightNoPickerView.reloadAllComponents()
			}
		})
	}
	
	
	@IBAction func goButtonPressed() {
		
		let tintColor = UIColor(red: 0.85, green: 0.83, blue: 0.45, alpha: 1.0)
		tintBackgroundColor(layer: goButton.layer, toColor: tintColor)
		roundCorners(layer: goButton.layer, toRadius: 25.0)
		
		//Navigation and Utilities
		self.counters = []
		self.performSegue(withIdentifier: "showTabBarController", sender: self)
	}
	
	func showBalloonAnimation(){
		let balloon = CALayer()
		balloon.contents = UIImage(named: "balloon")!.cgImage
		balloon.frame = CGRect(x: -50.0, y: 0.0,
		                       width: 50.0, height: 65.0)
		view.layer.insertSublayer(balloon, below: airportNameTF.layer)
		
		let flight = CAKeyframeAnimation(keyPath: "position")
		flight.duration = 12.0
		flight.values = [
			CGPoint(x: -50.0, y: 0.0),
			CGPoint(x: view.frame.width + 50.0, y: 160.0),
			CGPoint(x: -50.0, y: goButton.center.y)
			].map { NSValue(cgPoint: $0) }
		flight.keyTimes = [0.0, 0.5, 1.0]
		balloon.add(flight, forKey: nil)
		balloon.position = CGPoint(x: -50.0, y: goButton.center.y)
	}
	
//	func showMessage(index: Int) {
//		label.text = messages[index]
//		
//		UIView.transition(with: status, duration: 0.33, options:
//			[.curveEaseOut, .transitionFlipFromBottom], animations: {
//				self.status.isHidden = false
//		}, completion: {_ in
//			//transition completion
//			delay(seconds: 2.0) {
//				if index < self.messages.count-1 {
//					self.removeMessage(index: index)
//				} else {
//					//reset form
//					self.resetForm()
//				}
//			}
//		})
//	}
	
//	func removeMessage(index: Int) {
//		UIView.animate(withDuration: 0.33, delay: 0.0, options: [], animations: {
//			self.status.center.x += self.view.frame.size.width
//		}, completion: {_ in
//			self.status.isHidden = true
//			self.status.center = self.statusPosition
//			
//			self.showMessage(index: index+1)
//		})
//	}
	
//	func resetForm() {
//		UIView.transition(with: status, duration: 0.2, options: .transitionFlipFromTop, animations: {
//			self.status.isHidden = true
//			self.status.center = self.statusPosition
//		}, completion: nil)
//		
//		UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
//			self.spinner.center = CGPoint(x: -20.0, y: 16.0)
//			self.spinner.alpha = 0.0
//			self.loginButton.bounds.size.width -= 80.0
//			self.loginButton.center.y -= 60.0
//		}, completion: {_ in
//			let tintColor = UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1.0)
//			self.tintBackgroundColor(layer: self.loginButton.layer, toColor: tintColor)
//			self.roundCorners(layer: self.loginButton.layer, toRadius: 10.0)
//		})
//		
//		let wobble = CAKeyframeAnimation(keyPath: "transform.rotation")
//		wobble.duration = 0.25
//		wobble.repeatCount = 4
//		wobble.values = [0.0, -M_PI_4/4, 0.0, M_PI_4/4, 0.0]
//		wobble.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
//		heading.layer.add(wobble, forKey: nil)
//		
//	}
	
	func animateCloud(_ layer: CALayer) {
		//1
		let cloudSpeed = 60.0 / Double(view.layer.frame.size.width)
		let duration: TimeInterval = Double(view.layer.frame.size.width - layer.frame.origin.x) * cloudSpeed
		
		//2
		let cloudMove = CABasicAnimation(keyPath: "position.x")
		cloudMove.duration = duration
		cloudMove.toValue = self.view.bounds.size.width + layer.bounds.width/2
		cloudMove.delegate = self
		cloudMove.setValue("cloud", forKey: "name")
		cloudMove.setValue(layer, forKey: "layer")
		
		layer.add(cloudMove, forKey: nil)
	}
	
	func tintBackgroundColor(layer: CALayer, toColor: UIColor) {
		
		//challenge #2
		let tint = CASpringAnimation(keyPath: "backgroundColor")
		tint.damping = 5.0
		tint.initialVelocity = -10.0
		tint.fromValue = layer.backgroundColor
		tint.toValue = toColor.cgColor
		tint.duration = tint.settlingDuration
		layer.add(tint, forKey: nil)
		layer.backgroundColor = toColor.cgColor
	}
	
	func roundCorners(layer: CALayer, toRadius: CGFloat) {
		
		//challenge #1
		let round = CASpringAnimation(keyPath: "cornerRadius")
		round.damping = 5.0
		round.fromValue = layer.cornerRadius
		round.toValue = toRadius
		round.duration = round.settlingDuration
		layer.add(round, forKey: nil)
		layer.cornerRadius = toRadius
	}
	
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//		print("animation did finish")
		
		if let name = anim.value(forKey: "name") as? String {
			if name == "form" {
				//form field found
				let layer = anim.value(forKey: "layer") as? CALayer
				anim.setValue(nil, forKey: "layer")
				
				let pulse = CASpringAnimation(keyPath: "transform.scale")
				pulse.damping = 7.5
				pulse.fromValue = 1.25
				pulse.toValue = 1.0
				pulse.duration = pulse.settlingDuration
				layer?.add(pulse, forKey: nil)
			}
			
			if name == "cloud" {
				if let layer = anim.value(forKey: "layer") as? CALayer {
					anim.setValue(nil, forKey: "layer")
					
					layer.position.x = -layer.bounds.width/2
					delay(seconds: 0.5, completion: {
						self.animateCloud(layer)
					})
				}
			}
		}
	}
	

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		if segue.identifier == "showTabBarController"{
			if let tabVC = segue.destination as? CarrierTabBarController{
				//				tabVC.counters = self.counters
				tabVC.airportName = self.airportNameTF.text
				tabVC.carrierName = self.carrierNameTF.text
				tabVC.flightNo = self.flightNoTF.text
			}
		}
	}


}

//MARK:- Text Field Delegate

extension DashboardViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		print(info.layer.animationKeys())
		info.layer.removeAnimation(forKey: "infoappear")
	}
	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField.text?.characters.count < 5 {
			// add animations here
			let jump = CASpringAnimation(keyPath: "position.y")
			jump.initialVelocity = 100.0
			jump.mass = 10.0
			jump.stiffness = 1500.0
			jump.damping = 50.0
			
			jump.fromValue = textField.layer.position.y + 1.0
			jump.toValue = textField.layer.position.y
			jump.duration = jump.settlingDuration
			textField.layer.add(jump, forKey: nil)
			
			textField.layer.borderWidth = 3.0
			textField.layer.borderColor = UIColor.clear.cgColor
			
			let flash = CASpringAnimation(keyPath: "borderColor")
			flash.damping = 7.0
			flash.stiffness = 200.0
			flash.fromValue = UIColor(red: 0.96, green: 0.27, blue: 0.0, alpha: 1.0).cgColor
			flash.toValue = UIColor.clear.cgColor
			flash.duration = flash.settlingDuration
			textField.layer.add(flash, forKey: nil)
			
			self.goButton.isEnabled = false
		}
		else{
			self.showBalloonAnimation()
			if textField == self.flightNoTF{
				self.goButton.isEnabled = true
			}
		}
	}
}

//MARK:- Picker Delegate
extension DashboardViewController:UIPickerViewDelegate, UIPickerViewDataSource{
	
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
		else if pickerView == self.flightNoPickerView{
			if let flights = self.airports[self.airportNameTF.text!]?[self.carrierNameTF.text!]{
				return flights.count
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
				return Array(carriers.keys)[row]
			}
			else{
				return "Please Select an Airport"
			}
		}
		else if pickerView == self.flightNoPickerView{
			if let flights = self.airports[self.airportNameTF.text!]?[self.carrierNameTF.text!]{
				return Array(flights)[row]
			}
			else{
				return "Please Select a Carrier"
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
				self.carrierNameTF.text = Array(carriers.keys)[row]
			}
			else{
				self.carrierNameTF.text = ""
			}
		}
		else if pickerView == self.flightNoPickerView{
			if let flights = self.airports[self.airportNameTF.text!]?[self.carrierNameTF.text!]{
				self.flightNoTF.text = Array(flights)[row]
			}
			else{
				self.flightNoTF.text =  ""
			}
		}
		self.view.endEditing(true)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		view.endEditing(true)
	}
}
