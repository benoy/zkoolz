//
//  ZKGameConfig.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 20/06/24.
//

import Foundation

class ZKGameConfig {
    
    var maxWordCount: Int
    var point: Int
    var negativePoint: Int
    var time: Int
    
    var maxScore: Int {
        (point * maxWordCount) / 2
    }
   
    let level: ZKGameLevel

    init(level: ZKGameLevel) {
        self.level = level
        switch level {
            
        case .novice:
            
            self.maxWordCount = 20
            self.point = 1
            self.negativePoint = 0
            self.time = 80
            
        case .intermediate:
            
            self.maxWordCount = 30
            self.point = 1
            self.negativePoint = 0
            self.time = 60
        
        case .experienced:
            
            self.maxWordCount = 20
            self.point = 1
            self.negativePoint = 1
            self.time = 40
            
            
        case .professional:
            
            self.maxWordCount = 30
            self.point = 2
            self.negativePoint = 1
            self.time = 30
        
        case .guru:
            
            self.maxWordCount = 30
            self.point = 2
            self.negativePoint = 1
            self.time = 15

        }
    }
}


class ZKGameState {
    
    
    var point: Int = 0
    var usedWords: Set<ZKWord> = Set<ZKWord>()
    var timeCounter: Int = -1
    private var timer: Timer?
    
    var didReachTimeLimit: () -> Void = { }
    var shouldUpdateCount: (Int) -> Void = { _ in }
    
    var wordCount: Int {
        return usedWords.count
    }
    
    func reset() {
        point = 0
        usedWords = Set<ZKWord>()
    }
    
    func startCountdown(from maxCount: Int) {
        stopTimer()
        self.timeCounter = maxCount + 1
        DispatchQueue.main.sync { [weak self] in
            guard let self = self else { return }
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block:  {  timer in
                self.timeCounter -= 1
                
                if self.timeCounter <= 0 {
                    self.didReachTimeLimit()
                    self.stopTimer()
                } else {
                    self.shouldUpdateCount(self.timeCounter)
                }
            })
        }
        
        timer?.fire()
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
