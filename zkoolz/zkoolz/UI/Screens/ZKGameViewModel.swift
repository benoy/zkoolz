//
//  ZKGameViewModel.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 16/06/24.
//

import Foundation

protocol ZKGameViewModelDelegate {
    
    func shouldUpdate(countdown: Int)
    func shouldStopCountdown()
    func didReachTimeLimit()
    func didFInishLevel(point: Int)
    func shouuldUpdateTotal()
    func didSuggestWord(mesasge: String, isSuccess: Bool)
}


class ZKGameViewModel {
    
    
    var delegate: ZKGameViewModelDelegate!
    
    private var gameEngine: ZKGameable!
    private var shownWord: ZKWord?
    private var lastLetter: String = ""
    private var score: Int = 0
    private var totalScore: Int = 0

    
    init(gameEngine: ZKGameable = ZKGemeEngine()) {
        self.gameEngine = gameEngine
    }
    
    var levelTitle: String {
        var str = gameEngine.level.rawValue
        str = score > 0 ? str + " - score: \(score)" : str

        return str
    }
    
    var wordCountString : String {
        "Number of words : \(gameEngine.state.wordCount)"
    }
    
    var levelFishMessage: String {
        return "This level has been finished. You gained \(gameEngine.state.point) points in this level. Do you want to play again this level ?"
    }
    
    var pointsString: String {
        return "Current points in this level : \(gameEngine.state.point) (out of \(gameEngine.config.maxScore))"
    }
    
    var totalScoreString: String {
        return "Total score in this level:  \(totalScore)"
    }
    
    func start() {
        
        gameEngine.loadCurrentScore()
        
        gameEngine.didLoadScore = {[weak self] score in
            self?.totalScore = score?.points ?? 0
        }
        
        gameEngine.shouldUpdateCount = { [weak self] cnt in
            self?.delegate?.shouldUpdate(countdown: cnt)
        }
        
        gameEngine.didReachTimeLimit = { [weak self] in
            self?.delegate.didReachTimeLimit()
        }
        
        gameEngine.didFinishLevel = {  [weak self] level, point in
            self?.delegate.didFInishLevel(point: point)
            self?.updateScore()
        }
        
        gameEngine.initialise()
    }
    
    var randomWord: ZKWord?  {
        get async {
            shownWord = await gameEngine.randomWord()
            if let str = shownWord?.word.last {
                lastLetter = str.uppercased()
            }
            return shownWord
        }
    }
    
    var nextWord: ZKWord? {
        
        get async {
            shownWord = await gameEngine.getWord(letter: lastLetter)
            if let str = shownWord?.word.last {
                lastLetter = str.uppercased()
            }
            
            return shownWord
        }
    }

    
    var lastLetterMessage: String {
        return "Please type a word that starts with the letter '\(lastLetter)'."
    }
    
    func validate(word: String) async -> (ZKValidationError?, String) {
        
        guard let fstAlpha =  word.first?.uppercased(), fstAlpha ==  lastLetter  else {
            return (.wrongPrefix, lastLetterMessage)
        }
        
        let isInDB = await gameEngine.validate(wrod: word, firstAlpha: lastLetter)
        
        if !isInDB {
            let result =  await gameEngine.validateWithExternalDictionary(word: word)
            
            if result == .notInDB {
                return (.notInDB, "This word is not in our DB, please add this into our suggestion list.")
            } else if result == .alreadyUsed {
                return (.alreadyUsed, "You have used this word before in this round.")
            }
        }
        lastLetter = word.last?.uppercased() ?? ""
        return (nil, "")
    }
    
    func updateScore() {
        Task {[weak self] in
            guard let self = self else { return }
            let total = self.totalScore + self.gameEngine.state.point
            _ = await self.gameEngine.update(points: total)
            self.delegate.shouuldUpdateTotal()
        }
    }
    
    func suggestNew(word: String, meaning: String) {
        
        if word.isEmpty || meaning.isEmpty {
            delegate.didSuggestWord(mesasge: "Provide word and meaning in the given fields.",
                                    isSuccess: false)
            return
        }
        
        let wrd = ZKWord(word: word, meaning: meaning)
        
        Task { [weak self] in
            let result = await self?.gameEngine.addSuggestion(word: wrd)
            
            if result == false  {
                self?.delegate.didSuggestWord(mesasge: "We are unable to add the specified word in our suggestion list",
                                             isSuccess: false)
            } else {
                self?.delegate.didSuggestWord(mesasge: "We have added the word '\(word)' in our list for review.",
                                             isSuccess: true)
            }
        }
    }
  
}
