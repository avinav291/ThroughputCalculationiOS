//
//  BoardingDetailsViewController.swift
//  Throughput Calculation
//
//  Created by Avinav Goel on 01/04/17.
//  Copyright © 2017 Avinav Goel. All rights reserved.
//

import UIKit
import QuartzCore
import Firebase

//
//func delay(seconds: Double, completion:@escaping ()->()) {
//	let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
//	
//	DispatchQueue.main.asyncAfter(deadline: popTime) {
//		completion()
//	}
//}

enum AnimationDirection: Int {
	case positive = 1
	case negative = -1
}


class BoardingDetailsViewController: UIViewController {

	@IBOutlet var bgImageView: UIImageView!
	
	@IBOutlet var summaryIcon: UIImageView!
	@IBOutlet var summary: UILabel!
	
	@IBOutlet var flightNr: UILabel!
	@IBOutlet var gateNr: UILabel!
	@IBOutlet var departingFrom: UILabel!
	@IBOutlet var arrivingTo: UILabel!
	@IBOutlet var planeImage: UIImageView!
	
	@IBOutlet var flightStatus: UILabel!
	@IBOutlet var statusBanner: UIImageView!
	
	var snowView: SnowView!
	
	var ref = Database.database().reference()
	
	var airportName:String!
	var carrierName:String!
	var flightNo:String!
	
	//MARK: view controller methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//adjust ui
		summary.addSubview(summaryIcon)
		summaryIcon.center.y = summary.frame.size.height/2
		
		//add the snow effect layer
		snowView = SnowView(frame: CGRect(x: -150, y:-100, width: 300, height: 50))
		let snowClipView = UIView(frame: view.frame.offsetBy(dx: 0, dy: 50))
		snowClipView.clipsToBounds = true
		snowClipView.addSubview(snowView)
		view.addSubview(snowClipView)
		
//		//start rotating the flights
//		changeFlightDataTo(londonToParis)
		self.getFlightDetails()
	}
	
	func getFlightDetails(){
		
		ref.child("\(self.airportName!)/\(self.carrierName!)/flight/\(self.flightNo!)").observe(.value, with: { (snapshot) in
			if let snap = snapshot.value as? [String:Any]{
				
				let dateFormatter = DateFormatter()
				dateFormatter.timeStyle = .medium
				dateFormatter.dateStyle = .long
				
				let delayed = Double(snap["delayed"] as! String)!
				
				if delayed > 0.0{
					let delayedFlight = FlightData(
						summary: dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(Double(snap["departureTime"] as! String)!/1000.0))),
						flightNr: self.flightNo,
						gateNr: snap["boardingGate"] as! String,
						departingFrom: snap["source"] as! String,
						arrivingTo: snap["destination"] as! String,
						weatherImageName: "bg-sunny",
						showWeatherEffects: false,
						isTakingOff: false,
						flightStatus: "Delayed by \(Int(delayed/60)) mins")
					self.changeFlightDataTo(delayedFlight, animated: true)
				}
				else{
					let flight = FlightData(
						summary: dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(Double(snap["departureTime"] as! String)!/1000.0))),
						flightNr: self.flightNo,
						gateNr: snap["boardingGate"] as! String,
						departingFrom: snap["source"] as! String,
						arrivingTo: snap["destination"] as! String,
						weatherImageName: "bg-snowy",
						showWeatherEffects: true,
						isTakingOff: true,
						flightStatus: "Boarding")
					self.changeFlightDataTo(flight, animated: true)
				}
				
				
				
				
				//				let timeInterval = TimeInterval(Double(snap["arrivalTime"] as! String)!/1000.0)
				//				let timeInterval = (snap["arrivalTime"] as! TimeInterval)
				//				let date = Date(timeIntervalSince1970: TimeInterval(Double(snap["arrivalTime"] as! String)!/1000.0))
				
				//				self.arrivalTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(Double(snap["arrivalTime"] as! String)!/1000.0)))
				
				//				self.sourceLabel.text = snap["source"] as? String
				//				self.destinationLabel.text = snap["destination"] as? String
				//				self.arrivalTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(Double(snap["arrivalTime"] as! String)!/1000.0)))
				//				self.departureTimeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(Double(snap["departureTime"] as! String)!/1000.0)))
				//				self.boardingGateLabel.text = snap["boardingGate"] as? String
			}
		})
	}
	
	//MARK: custom methods
	
	func changeFlightDataTo(_ data: FlightData, animated: Bool = false) {
		
		// populate the UI with the next flight's data
		summary.text = data.summary
		
		if animated {
			planeDepart()
			
			fadeImageView(bgImageView,
			              toImage: UIImage(named: data.weatherImageName)!,
			              showEffects: data.showWeatherEffects)
			
			let direction: AnimationDirection = data.isTakingOff ?
				.positive : .negative
			
			cubeTransition(label: flightNr, text: data.flightNr,
			               direction: direction)
			cubeTransition(label: gateNr, text: data.gateNr,
			               direction: direction)
			
			let offsetDeparting = CGPoint(
				x: CGFloat(direction.rawValue * 80),
				y: 0.0)
			moveLabel(departingFrom, text: data.departingFrom,
			          offset: offsetDeparting)
			
			let offsetArriving = CGPoint(
				x: 0.0,
				y: CGFloat(direction.rawValue * 50))
			moveLabel(arrivingTo, text: data.arrivingTo,
			          offset: offsetArriving)
			
			cubeTransition(label: flightStatus, text: data.flightStatus, direction: direction)
			
		} else {
			bgImageView.image = UIImage(named: data.weatherImageName)
			snowView.isHidden = !data.showWeatherEffects
			
			flightNr.text = data.flightNr
			gateNr.text = data.gateNr
			
			departingFrom.text = data.departingFrom
			arrivingTo.text = data.arrivingTo
			
			flightStatus.text = data.flightStatus
		}
		
//		// schedule next flight
//		delay(seconds: 3.0) {
//			self.changeFlightDataTo(data.isTakingOff ? parisToRome : londonToParis, animated: true)
//		}
		
	}
	
	func fadeImageView(_ imageView: UIImageView, toImage: UIImage, showEffects: Bool) {
		
		UIView.transition(with: imageView, duration: 1.0,
		                  options: .transitionCrossDissolve, animations: {
							imageView.image = toImage
		}, completion: nil)
		
		UIView.animate(withDuration: 1.0, delay: 0.0,
		               options: .curveEaseOut, animations: {
						self.snowView.alpha = showEffects ? 1.0 : 0.0
		}, completion: nil)
	}
	
	func cubeTransition(label: UILabel, text: String, direction: AnimationDirection) {
		
		let auxLabel = UILabel(frame: label.frame)
		auxLabel.text = text
		auxLabel.font = label.font
		auxLabel.textAlignment = label.textAlignment
		auxLabel.textColor = label.textColor
		auxLabel.backgroundColor = label.backgroundColor
		
		let auxLabelOffset = CGFloat(direction.rawValue) *
			label.frame.size.height/2.0
		
		auxLabel.transform = CGAffineTransform(scaleX: 1.0, y: 0.1).concatenating(CGAffineTransform(translationX: 0.0, y: auxLabelOffset))
		
		label.superview!.addSubview(auxLabel)
		
		UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
			auxLabel.transform = CGAffineTransform.identity
			label.transform = CGAffineTransform(scaleX: 1.0, y: 0.1).concatenating(CGAffineTransform(translationX: 0.0, y: -auxLabelOffset))
		}, completion: {_ in
			label.text = auxLabel.text
			label.transform = CGAffineTransform.identity
			
			auxLabel.removeFromSuperview()
		})
		
	}
	
	
	func moveLabel(_ label: UILabel, text: String, offset: CGPoint) {
		
		let auxLabel = UILabel(frame: label.frame)
		auxLabel.text = text
		auxLabel.font = label.font
		auxLabel.textAlignment = label.textAlignment
		auxLabel.textColor = label.textColor
		auxLabel.backgroundColor = UIColor.clear
		
		auxLabel.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
		auxLabel.alpha = 0
		view.addSubview(auxLabel)
		
		UIView.animate(withDuration: 0.5, delay: 0.0,
		               options: .curveEaseIn, animations: {
						label.transform = CGAffineTransform(
							translationX: offset.x, y: offset.y)
						label.alpha = 0.0
		}, completion: nil)
		
		UIView.animate(withDuration: 0.25, delay: 0.1,
		               options: .curveEaseIn, animations: {
						auxLabel.transform = CGAffineTransform.identity
						auxLabel.alpha = 1.0
						
		}, completion: {_ in
			//clean up
			auxLabel.removeFromSuperview()
			
			label.text = text
			label.alpha = 1.0
			label.transform = CGAffineTransform.identity
		})
	}
	
	func planeDepart() {
		let originalCenter = planeImage.center
		
		UIView.animateKeyframes(withDuration: 1.5, delay: 0.0, options: [], animations: {
			//add keyframes
			
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: {
				self.planeImage.center.x += 80.0
				self.planeImage.center.y -= 10.0
			})
			
			UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.4) {
				self.planeImage.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/8))
			}
			
			UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
				self.planeImage.center.x += 100.0
				self.planeImage.center.y -= 50.0
				self.planeImage.alpha = 0.0
			}
			
			UIView.addKeyframe(withRelativeStartTime: 0.51, relativeDuration: 0.01) {
				self.planeImage.transform = CGAffineTransform.identity
				self.planeImage.center = CGPoint(x: 0.0, y: originalCenter.y)
			}
			
			UIView.addKeyframe(withRelativeStartTime: 0.55, relativeDuration: 0.45) {
				self.planeImage.alpha = 1.0
				self.planeImage.center = originalCenter
			}
			
		}, completion: nil)
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
