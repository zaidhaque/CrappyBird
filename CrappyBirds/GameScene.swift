//
//  GameScene.swift
//  CrappyBirds
//
//  Created by Daniel Hauagge on 3/17/16.
//  Copyright (c) 2016 Daniel Hauagge. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var background : SKSpriteNode!
    
    var bird : SKSpriteNode!
    var birdTextureAtlas = SKTextureAtlas(named: "player.atlas")
    var birdTextures = [SKTexture]()
    
    var floors = [SKSpriteNode]()
    var pipes = [SKSpriteNode]()
    
    var topPipeY = CGFloat(0)
    var bottomPipeY = CGFloat(0)
    
    var pipeSpacing = CGFloat(800)
    
    let BIRD_CAT  : UInt32 = 0x1 << 0;
    let FLOOR_CAT : UInt32 = 0x1 << 1;
    let PIPE_CAT  : UInt32 = 0x1 << 2;

    
    override func didMoveToView(view: SKView) {
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsWorld.contactDelegate = self

        // Background
        background = SKSpriteNode(imageNamed: "background")
        background.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        background.zPosition = -1000
        addChild(background)
        
        self.backgroundColor = SKColor(red: 80.0/255.0,
            green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)

        
        // Bird
        for texFName in birdTextureAtlas.textureNames.sort() {
            birdTextures.append(birdTextureAtlas.textureNamed(texFName))
        }
        bird = SKSpriteNode(texture: birdTextures[0])
        bird.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        bird.size.width /= 10
        bird.size.height /= 10
        let birdAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(birdTextures, timePerFrame: 0.1))
        bird.runAction(birdAnimation)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
        bird.physicsBody?.linearDamping = 1.1
        bird.physicsBody?.restitution = 0
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = BIRD_CAT
        bird.physicsBody?.collisionBitMask = FLOOR_CAT | PIPE_CAT
        bird.physicsBody?.contactTestBitMask = PIPE_CAT
        
        let particlesPath = NSBundle.mainBundle().pathForResource("MyParticle", ofType: "sks")!
        
        let particles = NSKeyedUnarchiver.unarchiveObjectWithFile(particlesPath) as! SKEmitterNode!
        
        addChild(bird)
        
        
        // Floor
        for i in 0 ..< 2 {
            let floor = SKSpriteNode(imageNamed: "floor")
            floor.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
            floor.anchorPoint = CGPointZero
            floor.position = CGPointMake(CGFloat(i) * floor.size.width, 0)
            
            var rect = floor.frame
            rect.origin.x = 0
            rect.origin.y = 0
            floor.physicsBody = SKPhysicsBody(edgeLoopFromRect: rect)
            floor.physicsBody?.dynamic = false
            floor.physicsBody?.categoryBitMask = FLOOR_CAT
            
            addChild(floor)
            floors.append(floor)
        }
        
        // Pipes
        for i in 0 ..< 2 {
            // Bottom
            let bottomPipe = SKSpriteNode(imageNamed: "bottomPipe")
            bottomPipe.size.width *= 0.5
            bottomPipe.size.height *= 0.5
            bottomPipe.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
            
            bottomPipeY = CGRectGetMaxY(floors[i].frame) + 0.5 * bottomPipe.size.height
            bottomPipe.position.y = bottomPipeY
            bottomPipe.position.x = CGFloat(1 + i) + pipeSpacing
            
            addChild(bottomPipe)
            pipes.append(bottomPipe)
            
            // Top
            let topPipe = SKSpriteNode(imageNamed: "topPipe")
            topPipe.size.width *= 0.5
            topPipe.size.height *= 0.5
            topPipe.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
            
            topPipeY = CGRectGetMaxY(self.frame) - 0.5 * topPipe.size.height
            topPipe.position.y = topPipeY
            topPipe.position.x = CGFloat(1 + i) + pipeSpacing
            
            addChild(topPipe)
            pipes.append(topPipe)
            
        }
        
        for pipe in pipes {
            pipe.physicsBody = SKPhysicsBody(texture: pipe.texture!, size: pipe.size)
            pipe.physicsBody?.dynamic = false
            pipe.physicsBody?.categoryBitMask = PIPE_CAT

        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        bird.physicsBody?.applyImpulse(CGVectorMake(0, 150))

    }
    
    override func update(currentTime: CFTimeInterval) {
        let floorSpeed = CGFloat(4)
        let pipeSpeed = CGFloat(4)
        
        bird.position.x = CGRectGetMidX(frame)
        
        for floor in floors {
            floor.position.x -= floorSpeed
            
            if floor.position.x < -floor.size.width / 2 {
                floor.position.x += 2 * floor.size.width
            }
        }
        
        for pipe in pipes {
            pipe.position.x -= pipeSpeed
            
            if pipe.position.x < -pipe.size.width / 2 {
                pipe.position.x += 2 * pipeSpacing
            }
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        print("collision happened")
    }
   
}
