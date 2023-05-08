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
        self.spriteNode = SKSpriteNode(texture: texture, size: spriteSize)
        self.spriteNode!.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        
        // Add your sprite node to your scene
        self.addChild(self.spriteNode!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.spriteNode?.texture = SKTexture(imageNamed: "open")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.spriteNode?.texture = SKTexture(imageNamed: "closed")
    }
}
