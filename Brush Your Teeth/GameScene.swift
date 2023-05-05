//
//  GameScene.swift
//  Brush Your Teeth
//
//  Created by Renning Bruns on 5/3/23.
//

import SpriteKit
import GameplayKit

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
        self.toothbrush = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
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
}
