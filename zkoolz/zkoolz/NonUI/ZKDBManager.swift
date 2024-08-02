//
//  ZKDBManager.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 14/06/24.
//

import Foundation

// https://dictionaryapi.dev
// Github token = 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

/*
//ssh-keygen -t ed25519 -b 4096 -C "{vidya@ezemp.com}" -f {bitbucker-ssh}

// ssh-add ~/{bitbucker-ssh}

Host bitbucket.org
AddKeysToAgent yes
IdentityFile ~/.ssh/{/Users/binoyvijayan/bitbucker-ssh-ssh}
 
 
 
 */

protocol ZKDBManageable {
    func save(user: ZKUser) async -> (Bool, String?)
    func getWordsFor(letter: String) async  -> [ZKWord]?
    func addNew(word: ZKWord) async -> Bool 
    
    func save(score: ZKScore, isNew: Bool) async -> Bool
    func getCurrentScore() async -> ZKScore?
    
    func saveSuggestion(word: ZKWord) async -> Bool 
}


class ZKDBManager {
    
    private var fireDB: FireDBProtocol
    
    private var score: ZKScore?
    
    init(fireDB: FireDBProtocol = FireDB() ) {
        self.fireDB = fireDB
    }
        
    private static let userAuthIdKey = "User_Auth_Id_Key"
    private static let userPhoneKey = "User_Phone_Key"
    private static let userKey = "User_Key"
    
    static func saveUserAuth(id: String) {
        UserDefaults.standard.set(id, forKey: ZKDBManager.userAuthIdKey)
    }
    
    static func getUserAuthId() -> String {
        let str = UserDefaults.standard.string(forKey: ZKDBManager.userAuthIdKey) ?? ""
        return str
    }
    
    static func removeUserAuthId() {
        UserDefaults.standard.removeObject(forKey: ZKDBManager.userAuthIdKey)
    }
    
    static func saveUser(phone: String) {
        UserDefaults.standard.set(phone, forKey: ZKDBManager.userPhoneKey)
    }
    
    static func getUserPhone() -> String {
        let str = UserDefaults.standard.string(forKey: ZKDBManager.userPhoneKey) ?? ""
        return str
    }
    
    static func removeUserPhone() {
        UserDefaults.standard.removeObject(forKey: ZKDBManager.userPhoneKey)
    }
    
    static func save(user: ZKUser) {
        UserDefaults.standard.set(user.dictionary, forKey: userKey)
    }
    
    static func getUser() -> ZKUser? {
        let dict = UserDefaults.standard.object(forKey: userKey) as? [String: Any]
        let user = ZKUser(dictionary: dict)
        return user
    }
    
}


extension ZKDBManager: ZKDBManageable {
    
    func save(user: ZKUser) async -> (Bool, String?) {
        
        ZKDBManager.save(user: user)
        let path = "user/\(user.phone)"
        guard let resut =  await fireDB.addData(path: path, data: user) else { return (true, nil) }

        return (false, resut.localizedDescription)
    }
    
    func getUser() async -> ZKUser? {
        let path = "user/\(ZKDBManager.getUserPhone())"
        let result  = await fireDB.dataFor(path: path)
        let dict = result?.0 as? [String : Any]

        return ZKUser(dictionary: dict)
    }
    
    
    
    func getWordsFor(letter: String) async  -> [ZKWord]? {
        
        let path = "words/\(letter)"
        guard let result = await fireDB.dataFor(path: path) else { return nil }
        guard let wrds = result.0 as? [String: String] else { return nil }
        
        let words: [ZKWord] = wrds.map { (key, value) in
            return ZKWord(word: key, meaning: value)
        }

        return words
    }
    
    func addNew(word: ZKWord) async -> Bool {
        let firstAlpha = word.word.first?.uppercased() ?? ""
        if firstAlpha.isEmpty { return false}
        let path = "words/\(firstAlpha)"
        
        guard let _ = await fireDB.updateData(path: path, data: word) else { return false }

        return (true)
    }
    
    func getCurrentScore() async -> ZKScore? {
        
        let path = "score/\(ZKDBManager.getUserPhone())"
        let result  = await fireDB.dataFor(path: path)
        let score = ZKScore(dictionary: result?.0 as? [String : Any])
        
        return score
    }
    
    func save(score: ZKScore, isNew: Bool) async -> Bool {
        let path = "score/\(ZKDBManager.getUserPhone())"
        if !isNew {
            guard let _ = await fireDB.updateData(path: path, data: score) else { return false }
        } else {
            guard let _ = await fireDB.addData(path: path, data: score) else { return false }
        }
        return true
    }
    
    func saveSuggestion(word: ZKWord) async -> Bool {
        let path = "suggestion/\(ZKDBManager.getUserPhone())"
        var error = await fireDB.updateData(path: path, data: word)
        
        if error != nil {
            error = await fireDB.addData(path: path, data: word)
        }
        
        return error == nil
    }
    
    
    func bulkUpdate() {
        let path = "words/O"
        Task {
           _ = await fireDB.bulkUpdateData(path: path, data: arr)
            print("DONWE O")
        }
         
    }
}


let arr = 
    [
        ("Oasis", "a fertile spot in a desert where water is found"),
        ("Oath", "a solemn promise, often invoking a divine witness regarding one's future actions or behavior"),
        ("Oatmeal", "meal made from ground oats, used in breakfast cereals or other food"),
        ("Obedient", "complying or willing to comply with orders or requests; submissive to another's will")
       
    ]

