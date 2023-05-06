//
//  GameScene.swift
//  Brush Your Teeth
//
//  Created by Renning Bruns on 5/3/23.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let all: UInt32 = UInt32.max
    static let toothbrush: UInt32 = 0b1
    static let germ: UInt32 = 0b10
}

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var spinnyNode : SKShapeNode?
    private var toothbrush : SKNode?
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            spinnyNode.alpha = 0.3
            spinnyNode.zPosition = 2
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(self.addGerm),
                SKAction.wait(forDuration: 1.0)
            ])
        ))
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
      return CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func addGerm() {
        let germ = SKLabelNode()
        germ.text = "🦠"
        germ.fontSize = 20
        germ.horizontalAlignmentMode = .center
        germ.verticalAlignmentMode = .center
        
        let x = size.width/2 + 20
        let y = self.random(min: -(size.height/2 - 10), max: size.height/2 - 10)
        let speed = self.random(min: 2.0, max: 4.0)
        germ.position = CGPoint(x: -x, y: y)
        germ.zPosition = 5
        self.addChild(germ)
        
        germ.run(SKAction.sequence([
            SKAction.move(to: CGPoint(x: x, y: y), duration: speed),
            SKAction.removeFromParent()
        ]))
        
        germ.physicsBody = SKPhysicsBody(circleOfRadius: germ.fontSize)
        germ.physicsBody?.isDynamic = true // 2
        germ.physicsBody?.categoryBitMask = PhysicsCategory.germ // 3
        germ.physicsBody?.contactTestBitMask = PhysicsCategory.toothbrush // 4
        germ.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let touchedNodes = self.nodes(at: location)
            for node in touchedNodes.reversed() {
                if node.name == "toothbrush" {
                    node.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
                    self.toothbrush = node
                    self.toothbrush?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 250))
                    self.toothbrush?.physicsBody?.isDynamic = true
                    self.toothbrush?.physicsBody?.categoryBitMask = PhysicsCategory.toothbrush
                    self.toothbrush?.physicsBody?.contactTestBitMask = PhysicsCategory.germ
                    self.toothbrush?.physicsBody?.collisionBitMask = PhysicsCategory.none
                    self.toothbrush?.physicsBody?.usesPreciseCollisionDetection = true
                }
            }
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
        if let touch = touches.first, let node = self.toothbrush {
            let touchLocation = touch.location(in: self)
            node.position = touchLocation
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        self.toothbrush?.physicsBody = nil
        self.toothbrush = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        self.toothbrush?.physicsBody = nil
        self.toothbrush = nil
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
    func toothbrushDidCollideWithGerm(toothbrush: SKLabelNode, germ: SKLabelNode) {
        print("Hit")
        germ.removeFromParent()
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
      // 1
      var firstBody: SKPhysicsBody
      var secondBody: SKPhysicsBody
      if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
        firstBody = contact.bodyA
        secondBody = contact.bodyB
      } else {
        firstBody = contact.bodyB
        secondBody = contact.bodyA
      }
        print(firstBody, secondBody)
     
      // 2
      if ((firstBody.categoryBitMask & PhysicsCategory.toothbrush != 0) &&
          (secondBody.categoryBitMask & PhysicsCategory.germ != 0)) {
        if let germ = secondBody.node as? SKLabelNode,
          let toothbrush = firstBody.node as? SKLabelNode {
            toothbrushDidCollideWithGerm(toothbrush: toothbrush, germ: germ)
        }
      }
    }

}
