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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.positionImages(lineNumber: 1, lineCount: 5)
		self.positionImages(lineNumber: 2, lineCount: 6)
		self.positionImages(lineNumber: 3, lineCount: 8)
		self.positionImages(lineNumber: 4, lineCount: 4)
        // Do any additional setup after loading the view.
    }
	
	func positionImages(lineNumber:Int, lineCount:Int){
		
		let lineShift = 10+80*(lineNumber-1)
		
		var startX = CGFloat(self.imageContainerView.frame.origin.x + CGFloat(lineShift))
		var startY = self.imageContainerView.frame.origin.y+10
		
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
