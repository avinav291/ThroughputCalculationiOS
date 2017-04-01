//
//  MyScene.swift
//  TexturePacker-SpriteKit-Swift
//
//  Created by Joachim Grill on 12.12.14.
//  Copyright (c) 2014 CodeAndWeb GmbH. All rights reserved.
//

import SpriteKit


class MyScene: SKScene
{
    let sheet = CapGuy()
//	let sheet = walking_business_man()
//    var sequence: SKAction?
	var lineNodes:[[SKSpriteNode]]! = [[], [], [], []]
	var walkAnim : SKAction!
	var throughputLabel:[SKLabelNode] = [SKLabelNode(fontNamed: "AvenirNext-Bold"), SKLabelNode(fontNamed: "AvenirNext-Bold"), SKLabelNode(fontNamed: "AvenirNext-Bold"), SKLabelNode(fontNamed: "AvenirNext-Bold")]
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        // load background image, and set anchor point to the bottom left corner (default: center of sprite)
		let background = SKSpriteNode(texture: SKTexture(imageNamed: "newCarpet"));
//        let background = SKSpriteNode(texture: sheet.Background());
        background.anchorPoint = CGPoint(x: 0, y: 0)
		background.size = self.size
		background.position = CGPoint(x:0, y:0)
		background.zPosition = -1
        // add the background image to the SKScene; by default it is added to position 0,0 (bottom left corner) of the scene
        addChild(background)
		
		view.backgroundColor = UIColor.clear
//		view.backgroundColor = UIColor(patternImage: UIImage(named: "carpet")!)
		
        // in the first animation CapGuy walks from left to right, in the second one he turns from right to left
        let walk = SKAction.animate(with: sheet.capguy_walk(), timePerFrame: 0.033)
//		let walk = SKAction.animate(with: sheet.walking_business_man(), timePerFrame: 0.033)
//        let turn = SKAction.animate(with: sheet.capguy_turn(), timePerFrame: 0.033)

        // to walk over the complete iPad display, we have to repeat the animation
        walkAnim = SKAction.repeat(walk, count: 6)
        
        // we define two actions to move the sprite from left to right, and back;
//        var moveRight = SKAction.moveTo(x: 900, duration: walkAnim.duration)
//		let moveRight = SKAction.moveBy(x: 100, y: -100, duration: walkAnim.duration)
//        let moveLeft  = SKAction.moveTo(x: 100, duration: walkAnim.duration)
//		let moveLeft = SKAction.moveBy(x: -100, y: 100, duration: walkAnim.duration)
        // as we have only an animation with the CapGuy walking from left to right, we use a 'scale' action
        // to get a mirrored animation.
//        let mirrorDirection = SKAction.scaleX(to: -1, y:1, duration:0.0)
//        let resetDirection  = SKAction.scaleX(to: 1,  y:1, duration:0.0);
		
        // Action within a group are executed in parallel:
//        let walkAndMoveRight = SKAction.group([resetDirection,  walkAnim, moveRight]);
//        let walkAndMoveLeft  = SKAction.group([mirrorDirection, walkAnim, moveLeft]);
		
        // now we combine the walk+turn actions into a sequence, and repeat it forever
//		sequence = SKAction.sequence([walkAndMoveLeft])
//        sequence = SKAction.repeatForever(SKAction.sequence(walkAndMoveLeft));
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        // each time the user touches the screen, we create a new sprite, set its position, ...
//        let sprite = SKSpriteNode(texture: sheet.capguy_walk_0001())
//        sprite.position = CGPoint(x: CGFloat(arc4random() % 100) + 500.0, y: 40)
//        
//        // ... attach the action with the walk animation, and add it to our scene
//        sprite.run(sequence!)
//        addChild(sprite)
//    }
	
	func updateNodesToLine(laneNumber:Int, people:Int, throughput:Double, avgWaitingTime:Double){
		
		//Return if the lane Number if greadter then 4
		if laneNumber>4{
			return
		}
		var person = people
		if people>8{
			person = 8
		}
		
		let mirrorDirection = SKAction.scaleX(to: -1, y:1, duration:0.0)
		
		//More People than existing
		if self.lineNodes[laneNumber].count<person{
			
			let label = self.throughputLabel[laneNumber]
			
			if self.lineNodes[laneNumber].count == 0{
				//Add the Counter
				
				//Image
				let clock = SKSpriteNode(texture: SKTexture(imageNamed: "clock"))
				clock.size = CGSize(width: 100, height: 100)
				clock.position = CGPoint(x: CGFloat( 200.0*CGFloat(laneNumber) - 60.0), y: 800)
				addChild(clock)
				
				//Image
				let label = self.throughputLabel[laneNumber]
//				let scalingFactor = min(90 / label.frame.width, 90 / label.frame.height)
//				// Change the fontSize.
//				label.fontName = UIFont(name: "", size: )
				label.fontSize = 35.0
//				label.text = "\(round((100*throughput)/100))"
				label.fontColor = UIColor.black
//				label.size = CGSize(width: 100, height: 70)
				label.position = CGPoint(x: CGFloat( 200.0*CGFloat(laneNumber) - 60.0), y: 790)
				addChild(label)
				
				let sprite = SKSpriteNode(texture: SKTexture(imageNamed: "counter"))
				sprite.size = CGSize(width: 100, height: 70)
				sprite.position = CGPoint(x: CGFloat( 200.0*CGFloat(laneNumber) - 60.0), y: 700)
				addChild(sprite)
			}
			
			label.text = "\(round((100*throughput)/100))"
			
			for index in (self.lineNodes[laneNumber].count+1)...person{

				let sprite = SKSpriteNode(texture: sheet.capguy_walk_0001())
//				let sprite = SKSpriteNode(texture: sheet.frame_0_delay_0_04s())
				sprite.position = CGPoint(x: CGFloat(200*(laneNumber))+100.0, y: 40)
				let moveLeft = SKAction.moveBy(x: CGFloat(-200.0 + 40.0*Double(index)), y: CGFloat(600.0-50*Double(index)), duration:walkAnim.duration )
				let walkAndMoveLeft  = SKAction.group([mirrorDirection, walkAnim, moveLeft]);
				sprite.run(walkAndMoveLeft)
				self.lineNodes[laneNumber].append(sprite)
				addChild(sprite)
			}
		}
		else if self.lineNodes[laneNumber].count>person{
			let difference = self.lineNodes[laneNumber].count-person
			
			for _ in 0...difference-1{
				let sprite = self.lineNodes[laneNumber][0]
				self.lineNodes[laneNumber].remove(at: 0)
				sprite.removeFromParent()
			}
			for sprites in self.lineNodes[laneNumber]{
				
				let moveLeft = SKAction.moveBy(x: CGFloat(-40.0*Double(difference)), y: CGFloat(50*Double(difference)), duration:walkAnim.duration )
				let walkAndMoveLeft  = SKAction.group([mirrorDirection ,walkAnim, moveLeft]);
				sprites.run(walkAndMoveLeft)
			}
		}
	}
	
}






