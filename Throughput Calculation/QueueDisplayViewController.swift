//
//  QueueDisplayViewController.swift
//  Throughput Calculation
//
//  Created by Avinav Goel on 24/03/17.
//  Copyright © 2017 Avinav Goel. All rights reserved.
//

import UIKit

class QueueDisplayViewController: UIViewController {

	@IBOutlet weak var imageContainerView: UIView!
	
	var counters : [Counter] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		for counter in counters{
			self.positionImages(lineNumber: counter.counterNumber, lineCount: counter.counterCount)
		}
        // Do any additional setup after loading the view.
    }
	
	func positionImages(lineNumber:Int, lineCount:Int){
		
		let lineShift = 10+80*(lineNumber-1)
		
		var startX = CGFloat(lineShift)
		var startY = CGFloat(10.0)
		
		let bundle = Bundle(for: BoardView.self)
		let nib = bundle.loadNibNamed("BoardView", owner: self, options: nil)
		let timerView = nib?.first as! BoardView
		
		timerView.frame = CGRect(x: startX, y: startY, width: 40, height: 42)
		timerView.timeLabel.text = "Hi"
		imageContainerView.addSubview(timerView)
		startY+=53
		
		let imageView = UIImageView(frame: CGRect(x: startX, y: startY, width: 40, height: 40))
		imageView.image = UIImage(named:"stickManWalking")
		imageContainerView.addSubview(imageView)
		startY+=20
		let counterImageView = UIImageView(frame: CGRect(x: startX, y: startY, width: 40, height: 40))
		counterImageView.image = UIImage(named:"counter")
		imageContainerView.addSubview(counterImageView)
		startY+=50
		
		for _ in 1...lineCount{
			let imageView = UIImageView(frame: CGRect(x: startX, y: startY, width: 40, height: 40))
			imageView.image = UIImage(named:"stickManWalking")
			imageContainerView.addSubview(imageView)
			startX+=20
			startY+=40
		}
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
