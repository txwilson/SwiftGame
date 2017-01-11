//
//  GameScene.swift
//  Game
//
//  Created by Tyler Wilson on 12/5/16.
//  Copyright © 2016 Tyler Wilson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let hookVelocity: CGFloat = 1.0
    var lastHook: CFTimeInterval = 0
    let bubbleCategory = 0x1 << 1
    let obstacleCategory = 0x1 << 2
    let shark = SKSpriteNode(imageNamed: "shark")
    
    override func didMove(to view: SKView) {
        
        startTimer()
        
        self.backgroundColor = SKColor.cyan
        
        self.addHook()
        
        shark.setScale(0.20)
        shark.position = CGPoint(x: size.width / 2, y: shark.size.height / 2)
        addChild(shark)
        
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
    }
    
    
    func addHook(){
        let hook = SKSpriteNode(imageNamed: "hook")
        hook.setScale(0.05)
        
        hook.physicsBody = SKPhysicsBody(rectangleOf: hook.size)
        hook.physicsBody?.categoryBitMask = UInt32(obstacleCategory)
        hook.physicsBody?.isDynamic = true
        hook.physicsBody?.contactTestBitMask = UInt32(bubbleCategory)
        hook.physicsBody?.collisionBitMask = 0
        hook.physicsBody?.usesPreciseCollisionDetection = true
        hook.name = "hook"
        
        let random: CGFloat = CGFloat(arc4random_uniform(500))
        hook.position = CGPoint(x: random, y: self.frame.size.height - 20)
        self.addChild(hook)

        let hookSpeed = 3
        let moveTime = TimeInterval((Int(arc4random_uniform(UInt32(hookSpeed)))))
        
        let moveAction = SKAction.moveTo(y: self.frame.height / 7, duration: moveTime)
        let remove = SKAction.removeFromParent()
        hook.run(SKAction.sequence([moveAction, remove]))
    }

    
    func shootBubble(shotLocation: CGPoint){
        let bubble = SKSpriteNode(imageNamed: "bubble")
        bubble.name = "bubble"
        
        bubble.position.x = shark.position.x
        bubble.position.y = shark.position.y
        
        bubble.setScale(0.10)
        
        bubble.physicsBody = SKPhysicsBody(circleOfRadius: bubble.size.width / 2)
        bubble.physicsBody?.isDynamic = true
        bubble.physicsBody?.categoryBitMask = UInt32(bubbleCategory)
        bubble.physicsBody?.contactTestBitMask  = UInt32(obstacleCategory)
        bubble.physicsBody?.collisionBitMask = 0
        bubble.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(bubble)
        
        let bubbleEndPosition: CGPoint = CGPoint(x: shotLocation.x, y: shotLocation.y)
        let bubbleSpeed: CGFloat = 1000
        let bubbleMoveTime = size.width / bubbleSpeed
        
        let moveBubble = SKAction.move(to: bubbleEndPosition, duration: TimeInterval(bubbleMoveTime))
        //let actionMoveDone = SKAction.removeFromParent()
        bubble.run(SKAction.sequence([moveBubble]))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if currentTime - self.lastHook > 0{
            self.lastHook = currentTime + 1
            addHook()
        }
    }
    
    func startTimer(){
        let timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.displayScore), userInfo: nil, repeats: false)

    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            shootBubble(shotLocation: location)
            }
        }

    func moveObstacle(){
        self.enumerateChildNodes(withName: "hook", using: { (node, stop) ->
            Void in
            if let obstacle = node as? SKSpriteNode {
                obstacle.position = CGPoint(x: obstacle.position.x, y: obstacle.position.y)
                if obstacle.position.x < 0{
                    obstacle.removeFromParent()
                }
            }
        })
    }
    
    var score = 0
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody!
        var secondBody: SKPhysicsBody!
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & UInt32(bubbleCategory)) != 0 &&
            (secondBody.categoryBitMask & UInt32(obstacleCategory)) != 0 {
            childNode(withName: "hook")?.removeFromParent()
            childNode(withName: "bubble")?.removeFromParent()
            score = score + 1
        }
        
    }
    
    func displayScore(){
        let scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = String("Game Over, You're score was \(score)")
        scoreLabel.fontSize = 20
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        addChild(scoreLabel)
    }
    
}
extension CGPoint {
    var length: CGFloat { return sqrt(self.x * self.x + self.y * self.y) }
    
    var normalized: CGPoint { return CGPoint(x: self.x / self.length, y: self.y / self.length) }
}
