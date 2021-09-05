//
//  Tetris.swift
//  Tetris
//
//  Created by Sungbae Kim on 2015. 7. 3..
//  Copyright (c) 2015년 1minute2life. All rights reserved.
//

import UIKit


enum GameState: Int {
    case stop = 0
    case play
    case pause
}

public class Tetris: NSObject {
    // Notification
    static var LineClearNotification = "LineClearNotification"
    static var NewBrickDidGenerateNotification = "NewBrickDidGenerateNotification"
    static var GameStateChangeNotification = "GameStateChangeNotification"
    
    // font
    static func GameFont(_ fontSize:CGFloat) -> UIFont! {
        return UIFont(name: "ChalkboardSE-Regular", size: fontSize)
    }
    
    var gameView:GameView!
    var gameTimer:GameTimer!
    
    var gameState = GameState.stop
    
    public required init(gameView:GameView) {
        super.init()
        self.gameView = gameView
        self.initGame()
    }
    
    deinit {
        debugPrint("deinit Tetris")
    }
    
    fileprivate func initGame() {
        self.gameTimer = GameTimer(target: self, selector: #selector(Tetris.gameLoop))
        
        self.addLongPressAction(#selector(Tetris.longPressed(_:)), toView:self.gameView.gameBoard)
        
        self.addGameStateChangeNotificationAction(#selector(Tetris.gameStateChange(_:)))
        
        self.addRotateAction(#selector(Tetris.rotateBrick), toButton: self.gameView.rotateButton)
    }
    
    public func deinitGame() {
        self.stop()
        self.removeGameStateChangeNotificationAction()
        
        self.gameTimer = nil
        self.gameView = nil
    }
    
    @objc func gameStateChange(_ noti:Notification) {
        guard let userInfo = noti.userInfo as? [String:NSNumber] else { return }
        guard let rawValue = userInfo["gameState"] else { return }
        guard let toState = GameState(rawValue: rawValue.intValue) else { return }
        
        switch self.gameState {
        case .play:
            // pause
            if toState == GameState.pause {
                self.pause()
            }
            // stop
            if toState == GameState.stop {
                self.stop()
            }
        case .pause:
            // resume game
            if toState == GameState.play {
                self.play()
            }
            // stop
            if toState == GameState.stop {
                self.stop()
            }
        case .stop:
            // start game
            if toState == GameState.play {
                self.prepare()
                self.play()
            }
        }
    }
    
    
    @objc func longPressed(_ longpressGesture:UILongPressGestureRecognizer) {
        if self.gameState == GameState.play {
            if longpressGesture.state == UIGestureRecognizer.State.began {
                self.gameView.gameBoard.dropBrick()
            }
        }
    }

    @objc func gameLoop() {
        self.update()
        self.gameView.setNeedsDisplay()
    }
    fileprivate func update() {

        self.gameTimer.counter += 1
        
        if self.gameTimer.counter%10 == 9 {
            let game = self.gameView.gameBoard.update()
            if game.isGameOver {
                self.gameOver()
                return
            }
        }
    }
    
    fileprivate func prepare() {
        self.gameView.prepare()
        self.gameView.gameBoard.generateBrick()
    }
    fileprivate func play() {
        self.gameState = GameState.play
        self.gameTimer.start()
    }
    fileprivate func pause() {
        self.gameState = GameState.pause
        self.gameTimer.pause()
    }
    fileprivate func stop() {
        self.gameState = GameState.stop
        self.gameTimer.pause()
        
        self.gameView.clear()
    }

    fileprivate func gameOver() {
        self.gameState = GameState.stop
        self.gameTimer.pause()
        
        self.gameView.nextBrick.clearButtons()
    }
    
    // game interaction
    public func touch(_ touch:UITouch) {
        guard self.gameState == GameState.play else { return }
        guard let _ = self.gameView.gameBoard.currentBrick else { return }
        
        let p = touch.location(in: self.gameView.gameBoard)
        
        let half = self.gameView.gameBoard.centerX
        
        if p.x > half {
            self.gameView.gameBoard.updateX(1)
        } else if p.x < half {
            self.gameView.gameBoard.updateX(-1)
        }
    }
    
    @objc func rotateBrick() {
        guard self.gameState == GameState.play else { return }
        guard let _ = self.gameView.gameBoard.currentBrick else { return }
        
        self.gameView.gameBoard.rotateBrick()
    }
    
    fileprivate func addLongPressAction(_ action:Selector, toView view:UIView) {
        let longpressGesture = UILongPressGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(longpressGesture)
    }
    
    fileprivate func addGameStateChangeNotificationAction(_ action:Selector) {
        NotificationCenter.default.addObserver(self,
                                                         selector: action,
                                                         name: NSNotification.Name(rawValue: Tetris.GameStateChangeNotification),
                                                         object: nil)
    }
    fileprivate func removeGameStateChangeNotificationAction() {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func addRotateAction(_ action:Selector, toButton button:GameButton) {
        button.addTarget(self, action: action, for: .touchUpInside)
    }
    
}
