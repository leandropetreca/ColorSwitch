//
//  GameScene.swift
//  ColorSwitch
//
//  Created by Leandro Petreca on 06/08/18.
//  Copyright © 2018 Leandro Petreca. All rights reserved.
//

import SpriteKit

enum PlayColors {
    static let colors = [
        UIColor(red: 342/355, green: 76/255, blue: 60/255, alpha: 1.0),
        UIColor(red: 241/355, green: 196/255, blue: 15/255, alpha: 1.0),
        UIColor(red: 46/355, green: 204/255, blue: 113/255, alpha: 1.0),
        UIColor(red: 52/355, green: 152/255, blue: 219/255, alpha: 1.0)
    ]
    
}

enum SwitchState: Int {
    case red, yellow, green, blue
}

class GameScene: SKScene {
    
    var colorSwitch: SKSpriteNode!
    var switchState = SwitchState.red
    var currentColorIndex: Int?
    
    let scoreLable = SKLabelNode(text: "0")
    var score = 0 {
        didSet{
            updateScoreLable()
        }
    }
    
    override func didMove(to view: SKView) {
        layoutScene()
        setupPhysics()
    }
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.0)
        physicsWorld.contactDelegate = self
    }
    
    func layoutScene() {
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        colorSwitch = SKSpriteNode(imageNamed: "ColorCircle")
        colorSwitch.size = CGSize(width: frame.size.width/3, height: frame.size.width/3)
        colorSwitch.position = CGPoint(x: frame.midX, y: frame.midY - colorSwitch.size.height)
        colorSwitch.physicsBody = SKPhysicsBody(circleOfRadius: colorSwitch.size.width/2)
        colorSwitch.physicsBody?.categoryBitMask = PhysicsCategories.switchCategory
        colorSwitch.physicsBody?.isDynamic = false
        colorSwitch.zPosition = ZPositions.colorSwitch
        addChild(colorSwitch)
        
        scoreLable.fontName = "AvenirNext-Bold"
        scoreLable.fontSize = 60.0
        scoreLable.fontColor = UIColor.white
        scoreLable.position = CGPoint(x: frame.midX, y: frame.midY)
        scoreLable.zPosition = ZPositions.label
        addChild(scoreLable)
        
        spawnBall()
    }
    
    func updateScoreLable() {
        scoreLable.text = "\(score)"
    }
    
    func spawnBall() {
        currentColorIndex = Int(arc4random_uniform(UInt32(4)))
        
        let ball = SKSpriteNode(texture: SKTexture(imageNamed: "ball"), color: PlayColors.colors[currentColorIndex!], size: CGSize(width: 30.0, height: 30.0))
        ball.colorBlendFactor = 1.0
        ball.name = "Ball"
        ball.position = CGPoint(x: frame.midX, y: frame.height)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.switchCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        ball.zPosition = ZPositions.ball
        addChild(ball)
        
    }
    
    func turnWheel() {
        if let newState = SwitchState(rawValue: switchState.hashValue + 1) {
            switchState = newState
        } else {
            switchState = .red
        }
        
        colorSwitch.run(SKAction.rotate(byAngle: .pi/2, duration: 0.25))
        
        
    }
    
    func gameOver() {
        print("game over")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        turnWheel()
    }
    
   
}


extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.switchCategory {
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                if currentColorIndex == switchState.rawValue {
                    print("correct!")
                    score += 1
                    ball.run(SKAction.fadeOut(withDuration: 0.25)) {
                        ball.removeFromParent()
                        self.spawnBall()
                    }
                } else {
                    gameOver()
                }
            }
        }
    }
}
