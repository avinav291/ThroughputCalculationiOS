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
	
	var ref = Database.database().reference()

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
		self.getDetails()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
//		self.getDetails()
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
						self.counters.append(Counter(throughput: counter["throughput"] as? Double ?? 0.0, counterNumber: counter["counterNumber"] as? Int ?? 0, counterCount: counter["counterCount"] as? Int ?? 0, avgWaitingTime: (counter["throughput"] as? Double ?? 1.0)*(counter["counterCount"] as? Double ?? 1.0)))
						let counterTime:Double = (counter["throughput"] as? Double ?? 1.0)*(counter["counterCount"] as? Double ?? 1.0)
						if minAvgTime > counterTime{
							minAvgTime = counterTime
							self.minCounter = counter["counterNumber"] as? Int ?? 0
						}
					}
				}
				self.updateSKScene()
				self.moveToLabel.text = "Move To Counter \(self.minCounter!)"
			}
		})
	}
	
	func updateSKScene(){
		for counter in self.counters{

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
