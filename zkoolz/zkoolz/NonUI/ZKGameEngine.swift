//
//  ZKGameEngine.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 16/06/24.
//

import Foundation

enum ZKGameLevel: String {
    
    case novice = "Novice"
//    case beginner
//    case competent
    case intermediate = "Intermediate"
//    case proficient
//    case advanced
//    case skilled
    case experienced = "Experienced"
//    case expert
//    case master
    case professional = "Professional"
//    case authority
//    case virtuoso
    case guru = "Guru"
    
    static var array: [ZKGameLevel] {
        return [.novice, .intermediate, .experienced, .professional, .guru]
    }
    
    var imageName: String {
        self.rawValue
    }
    
}

enum ZKValidationError {
    
    case wrongPrefix
    case alreadyUsed
    case notInDB
    
}

protocol ZKGameable {
    
    var level: ZKGameLevel { get }
    var config: ZKGameConfig! { get }
    var state: ZKGameState! { get }
    
    var didReachTimeLimit: () -> Void { get set }
    var shouldUpdateCount: (Int) -> Void { get set }
    var didFinishLevel: (ZKGameLevel, Int) -> Void  { get set }
    var didLoadScore: (ZKLevelScore?) -> Void { get set}

    func initialise()
    func getWord(letter: String) async -> ZKWord?
    func randomWord() async -> ZKWord?
    func validate(wrod: String, firstAlpha: String) async -> Bool
    func validateWithExternalDictionary(word: String) async -> ZKValidationError?
    func loadCurrentScore()
    func update(points: Int) async -> Bool
    func addSuggestion(word: ZKWord) async -> Bool
    
}


class ZKGemeEngine: ZKGameable {
    
    
    private var dbManager: ZKDBManageable!
    private var apiManager: ZKAPIManageable!
    private var score: ZKScore?
    
    var config: ZKGameConfig!
    var state: ZKGameState!
    
    var didFinishLevel: (ZKGameLevel, Int) -> Void = {_ , _ in }
    var didReachTimeLimit: () -> Void = { }
    var shouldUpdateCount: (Int) -> Void = { _ in }
    var didLoadScore: (ZKLevelScore?) -> Void  = { _ in }
    
    
    init( level: ZKGameLevel = .novice,
          dbManager: ZKDBManageable = ZKDBManager(),
          apiManager: ZKAPIManageable = ZKAPIManager() ) {
        
        self.dbManager = dbManager
        self.apiManager = apiManager
        self.config = ZKGameConfig(level: level)
        self.state = ZKGameState()
    }
    
    func initialise() {
        state.didReachTimeLimit = didReachTimeLimit
        state.shouldUpdateCount = shouldUpdateCount
        state.reset()
    }
    
    var level: ZKGameLevel {
        return config.level
    }
    
    func loadCurrentScore() {
        Task { [weak self] in
            guard let self = self else { return }
            let currentScore = await dbManager.getCurrentScore()
            self.score = currentScore
            self.didLoadScore(currentScore?.levelScore[self.level])
        }
    }
    
    func update(points: Int) async -> Bool {
        
        guard let user = ZKDBManager.getUser() else { return false}
        var isNew = false
        if score == nil {
            score = ZKScore(name: user.name)
            isNew = true
        }
        score?.levelScore[level]?.points = points
        if let scr = score {
            let result = await dbManager.save(score: scr, isNew: isNew)
            return result
        }
        
        return false
    }
    
    func getRandomAlphabet() -> String {
        let ran = Int.random(in: 0...25)
        let num = 65 + ran
        
        if let scalar = UnicodeScalar(num) {
            let character = Character(scalar)
            return String(character)
        } else {
            return ""
        }
    }
    
    func getWord(letter: String) async -> ZKWord? {
        
        if state.usedWords.count >= config.maxWordCount {
            didFinishLevel(config.level, state.point)
            return nil
        }
        
        guard let words = await dbManager.getWordsFor(letter: letter) else { return nil }
        let cnt = words.count
        var word: ZKWord? = nil
        
        while word == nil || state.usedWords.contains(where: { word!.word.uppercased() == $0.word.uppercased() }) {
            let rnd = Int.random(in: 0..<cnt)
            word =  words[rnd]
        }
        
        state.startCountdown(from: config.time)
        state.usedWords.insert(word!)
        return word
    }
    
    func randomWord() async -> ZKWord? {
        let letter = getRandomAlphabet()
        guard let word = await getWord(letter: letter) else { return nil }
        state.usedWords.insert(word)
        
        return word
    }
    
    func validate(wrod: String, firstAlpha: String) async -> Bool {

        guard let words =  await dbManager.getWordsFor(letter: firstAlpha) else { return false }
        let filtered = words.filter{ $0.word.lowercased() == wrod.lowercased() }
        if filtered.count > 0 && state.usedWords.contains(filtered[0]) == false {
            state.stopTimer()
            state.usedWords.insert(filtered[0])
            state.point += 1
            return true
        }
        
        return false
    }
    
    func validateWithExternalDictionary(word: String) async -> ZKValidationError? {
        
        guard let wordObj =  await apiManager.getInfo(for: word)  else {
            return .notInDB
        }
        
        if state.usedWords.contains(wordObj) == false {
            state.stopTimer()
            Task { _ = await dbManager.addNew(word: wordObj) }
            state.usedWords.insert(wordObj)
            state.point += 1
            return nil
        }
        
        return .alreadyUsed
    }
    
    func addSuggestion(word: ZKWord) async -> Bool {
       return await dbManager.saveSuggestion(word: word)
    }
}
