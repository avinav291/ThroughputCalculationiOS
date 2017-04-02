//
//  AnimatedQueueDisplayViewController.swift
//  Throughput Calculation
//
//  Created by Avinav Goel on 26/03/17.
//  Copyright © 2017 Avinav Goel. All rights reserved.
//

import UIKit
import SpriteKit
import Firebase

class AnimatedQueueDisplayViewController: UIViewController {
	
	@IBOutlet weak var moveToLabel: UILabel!
	@IBOutlet weak var imageContainerView: SKView!
	var counters : [Counter] = []
	var airportName:String! = ""
	var carrierName:String! = ""
	var skView:SKView!
	var scene:MyScene!
	let defaults = UserDefaults.standard
	
	var minCounter:Int! = 0
	
	var ref = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		// Configure the view.
		skView = self.imageContainerView as SKView
//		skView.showsFPS = true
//		skView.showsNodeCount = true
		
		// Sprite Kit applies additional optimizations to improve rendering performance
		skView.ignoresSiblingOrder = true
		
		// Create and configure the scene. We use iPad dimensions, and crop the image on iPhone screen
		scene = MyScene(size: CGSize(width: 768, height: 900));
		scene.scaleMode = .aspectFill
		scene.view?.allowsTransparency = true
		scene.backgroundColor = UIColor.clear
		
		skView.allowsTransparency = true
		
		skView.presentScene(scene)
		
//		self.updateSKScene()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		self.getDetails()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
//		self.getDetails()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func getDetails(){
		ref.child("\(self.airportName!)/\(self.carrierName!)/carrier").observe(.value, with: { (snapshot) in
//			print(snapshot.value!)
			if let snap = snapshot.value as? NSArray{
//				print(snap)
				self.counters = []
				var minAvgTime = Double.infinity
				for lane in snap{
					if let counter = lane as? [String:Any]{
						self.counters.append(Counter(throughput: Double(counter["throughput"] as! String)!, counterNumber: Int(counter["counterNumber"] as! String)!, counterCount: Int(counter["counterCount"] as! String)!, avgWaitingTime: Double(counter["avgWaitingTime"] as! String)!))
						let counterTime:Double = Double(counter["avgWaitingTime"] as! String)!
						if minAvgTime > counterTime{
							minAvgTime = counterTime
							self.minCounter = Int(counter["counterNumber"] as! String)!
						}
					}
				}
				self.updateSKScene()
				self.moveToLabel.text = "Move To Counter \(self.minCounter!)"
			}
		})
	}
	
//	func getSmallestThroughputDetails(){
//		ref.child("\(self.airportName!)/\(self.carrierName!)/carrier").observe(.value, with: { (snapshot) in
//			//			print(snapshot.value!)
//			if let snap = snapshot.value as? NSArray{
//				//				print(snap)
//				var minAvgTime = Double.infinity
//				for lane in snap{
//					if let counter = lane as? [String:Any]{
//						let counterTime:Double = Double(counter["avgWaitingTime"] as! String)!
//						if minAvgTime > counterTime{
//							minAvgTime = counterTime
//							self.minCounter = Int(counter["counterNumber"] as! String)!
//						}
//					}
//				}
//				self.displayRouteInfo()
//			}
//		})
//	}
//	
//	func getDetails(){
//		let airportName = self.airportName
//		let carrierName = self.carrierName
//		
//		if airportName != "" && carrierName != ""{
//			
//			let ipAddress = defaults.string(forKey: "ipAddress")
//			
//			let url = URL(string: "http://\(ipAddress!)/api/sendQueueData")
//			let postString = "airportName=\(airportName!)&carrierName=\(carrierName!)"
//			let request = NSMutableURLRequest(url: url!)
//			request.httpMethod = "POST"
//			request.httpBody = postString.data(using: .utf8)
//			
//			let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
//				if error != nil {
//					print(error!)
//					return
//				}
//				do{
//					
//					let responseJson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
//					
//					if let json = responseJson as? [[String:Any]]{
//						
//						self.counters = []
//						for counter in json{
//							self.counters.append(Counter(throughput: counter["throughput"] as! Int, counterNumber: counter["counterNumber"] as! Int, counterCount: counter["counterCount"] as! Int))
//						}
//						self.updateSKScene()
//						DispatchQueue.main.async {
//							Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(self.getDetails), userInfo: nil, repeats: false)
//						}
//					}
//					
//					
//				}
//				catch{
//					print("Json Receiving error")
//				}
//			})
//			
//			task.resume()
//		}
//	}
	
	func updateSKScene(){
		for counter in self.counters{
//			let laneNumber = counter.counterNumber
//			let people = counter.counterCount
//			
			self.scene.updateNodesToLine(laneNumber: counter.counterNumber, people: counter.counterCount, throughput: counter.throughput, avgWaitingTime: counter.avgWaitingTime)
		}
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
