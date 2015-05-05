//
//  GameScene.swift
//  BreakoutSpriteKitTutorial
//
//  Created by André Helaehil on 05/05/15.
//  Copyright (c) 2015 André Helaehil. All rights reserved.
//

import SpriteKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let BlockNodeCategoryName = "blockNode"

let BallCategory : UInt32 = 0x1 << 0
let BottomCategory : UInt32 = 0x1 << 1
let BlockCategory : UInt32 = 0x1 << 2
let PaddleCategory : UInt32 = 0x1 << 3

class GameScene: SKScene, SKPhysicsContactDelegate {
    var isFingerOnPaddle = false
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        //Cria uma barreira invisível em volta da tela
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        //Remove a gravidade da cena
        physicsWorld.gravity = CGVectorMake(0, 0)
        
        //Delegate
        physicsWorld.contactDelegate = self
        
        //Pega a bola dos child nodes da cena usando o nome setado no Visual Editor
        let ball = childNodeWithName(BallCategoryName) as! SKSpriteNode
        ball.physicsBody?.applyImpulse(CGVectorMake(10, -10))
        
        //Cria um body que cobre o fundo da tela
        let bottomRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
        addChild(bottom)
        
        //Pega o paddle do Visual Editor
        let paddle = childNodeWithName(PaddleCategoryName) as! SKSpriteNode
        
        //Configurando contato com BitMask
        bottom.physicsBody?.categoryBitMask = BottomCategory
        ball.physicsBody?.categoryBitMask = BallCategory
        paddle.physicsBody?.categoryBitMask = PaddleCategory
        
        //"Notifica" se a bola faz contato com o fundo da tela ou o bloco
        ball.physicsBody?.contactTestBitMask = BottomCategory | BlockCategory
        
        //Configurando collisionBitMask
        ball.physicsBody?.collisionBitMask = PaddleCategory
        
        //Criando 5 blocos
        let numberOfBlocks = 5
        
        let blockWidth = SKSpriteNode(imageNamed: "block.png").size.width
        let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)
        
        let padding: CGFloat = 10.0
        let totalPadding = padding * CGFloat(numberOfBlocks-1)
        
        let xOffset = (CGRectGetWidth(frame) - totalBlocksWidth - totalPadding)/2
        
        for i in 0..<numberOfBlocks{
            let block = SKSpriteNode(imageNamed: "block.png")
            block.position = CGPointMake(xOffset + CGFloat(CGFloat(i) + 0.5)*blockWidth + CGFloat(i-1)*padding, CGRectGetHeight(frame)*0.8)
            block.physicsBody = SKPhysicsBody(rectangleOfSize: block.frame.size)
            block.physicsBody?.allowsRotation = false
            block.physicsBody?.friction = 0.0
            block.physicsBody?.affectedByGravity = false
            block.name = BlockCategoryName
            block.physicsBody?.categoryBitMask = BlockCategory
            block.physicsBody?.dynamic = false
            block.physicsBody?.collisionBitMask = 0
            addChild(block)
        }
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        let ball = self.childNodeWithName(BallCategoryName) as! SKSpriteNode
        
        let maxSpeed : CGFloat = 1000.0
        let speed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx + ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
        
        if speed > maxSpeed{
            ball.physicsBody?.linearDamping = 0.4
        }
        else{
            ball.physicsBody?.linearDamping = 0.0
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        //Acha o local do toque
        var touch = touches.first as! UITouch
        var touchLocation = touch.locationInNode(self)
        
        
        //Checa se tem um node no local do toque e se esse node é um paddle
        if let body = physicsWorld.bodyAtPoint(touchLocation){
            if body.node?.name == PaddleCategoryName{
                println("Began touch on paddle")
                isFingerOnPaddle = true
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if isFingerOnPaddle{
            var touch = touches.first as! UITouch
            var touchLocation = touch.locationInNode(self)
            var previousLocation = touch.previousLocationInNode(self)
            
            var paddle = childNodeWithName(PaddleCategoryName) as! SKSpriteNode
            
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            
            paddleX = max(paddleX, paddle.size.width/2)
            paddleX = min(paddleX, size.width - paddle.size.width/2)
            
            paddle.position = CGPointMake(paddleX, paddle.position.y)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        isFingerOnPaddle = false
        println("Ended touch on paddle")

    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory{
            if let mainView = view{
                let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as! GameOverScene
                gameOverScene.gameWon = false
                println("Hit bottom. First contact has been made.")
                mainView.presentScene(gameOverScene)
            }
        }
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory{
            secondBody.node?.removeFromParent()
            if isGameWon(){
                if let mainView = view{
                    let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as! GameOverScene
                    gameOverScene.gameWon = true
                    mainView.presentScene(gameOverScene)
                }
            }
        }
    }
    
    func isGameWon() -> Bool{
        var numberOfBricks = 0
        self.enumerateChildNodesWithName(BlockCategoryName){
            node, stop in
            numberOfBricks = numberOfBricks + 1
        }
        return numberOfBricks == 0
    }
    
    
}