//
//  GameOverScene.swift
//  BreakoutSpriteKitTutorial
//
//  Created by André Helaehil on 05/05/15.
//  Copyright (c) 2015 André Helaehil. All rights reserved.
//

import SpriteKit
let GameOverLabelCategoryName = "gameOverLabel"

class GameOverScene: SKScene {
    var gameWon: Bool = false {
        didSet{
            let gameOverLabel = childNodeWithName(GameOverLabelCategoryName) as! SKLabelNode
            gameOverLabel.text = gameWon ? "Game Won" : "Game Over"
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let view = view{
            let gameScene = GameScene.unarchiveFromFile("GameScene") as! GameScene
            view.presentScene(gameScene)
        }
    }
}

