//
//  GameScene.swift
//  Brush Your Teeth
//
//  Created by Renning Bruns on 5/3/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var spriteNode: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "yoko-honda")
        background.position = CGPoint(x: -10, y: -275)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(background)
        
        let screenSize = UIScreen.main.bounds.size
        let texture = SKTexture(imageNamed: "closed")
        let aspectRatio = texture.size().width / texture.size().height
        let proportion: CGFloat = 0.4
        let maxWidth = screenSize.width * proportion
        let maxHeight = screenSize.height * proportion
        var spriteSize = CGSize(width: maxWidth, height: maxHeight)
        if aspectRatio > 1 {
            spriteSize.height = spriteSize.width / aspectRatio
        } else {
            spriteSize.width = spriteSize.height * aspectRatio
        }

        // Create your sprite node with the calculated size and position it at the center of the screen
        spriteNode = SKSpriteNode(texture: texture, size: spriteSize)
        spriteNode!.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        
        addGerm(at: CGPoint(x: 10, y: -30))
        addGerm(at: CGPoint(x: -100, y: 0))
        addGerm(at: CGPoint(x: 50, y: -100))
        addGerm(at: CGPoint(x: -75, y: -95))

        // Add your sprite node to your scene
        addChild(spriteNode!)
    }
    
    func addGerm(at pos: CGPoint) {
        // add a germ sprite relative to the spriteNode
        let germSprite = SKLabelNode(text: "🦠")
        germSprite.name = "germ"
        germSprite.position = pos
        germSprite.isHidden = true
        spriteNode?.addChild(germSprite)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        spriteNode?.texture = SKTexture(imageNamed: "open")
        spriteNode?.enumerateChildNodes(withName: "germ") { child, _ in
            // Access each child sprite here and perform an action
            child.isHidden = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let nodes = self.nodes(at: touchLocation)
        for node in nodes {
            if node.name == "germ" {
                node.removeFromParent()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        spriteNode?.texture = SKTexture(imageNamed: "closed")
        spriteNode?.enumerateChildNodes(withName: "germ") { child, _ in
            // Access each child sprite here and perform an action
            child.isHidden = true
        }
    }
}
