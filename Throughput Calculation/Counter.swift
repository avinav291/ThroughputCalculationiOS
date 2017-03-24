//
//  Counter.swift
//  Throughput Calculation
//
//  Created by Avinav Goel on 24/03/17.
//  Copyright © 2017 Avinav Goel. All rights reserved.
//

import UIKit

class Counter: NSObject {
	var throughput:Int = 0
	var counterNumber:Int = 0
	var counterCount:Int = 0
	
	init(throughput:Int, counterNumber:Int, counterCount:Int){
		super.init()
		self.counterCount = counterCount
		self.counterNumber = counterNumber
		self.throughput = throughput
	}
}
