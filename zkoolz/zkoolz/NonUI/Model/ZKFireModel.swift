//
//  ZKFireModel.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 14/06/24.
//

import Foundation

class ZKUser: FireModel {
    
    let name: String
    let phone: String
    let authId: String
    
    init(authId: String, name: String, phone: String) {
        self.authId = authId
        self.name = name
        self.phone = phone
        super.init()
    }
    
    override init?(dictionary: [String : Any]?) {
        self.authId = dictionary?["authId"]  as? String ?? ""
        self.name = dictionary?["name"]  as? String ?? ""
        self.phone = dictionary?["phone"] as? String ?? ""
        super.init()
    }
    
    override var dictionary: [String: Any]?{
        get{
            ["name": name, "phone": phone]
        }
    }
    
}

//class ZKWords: FireModel {
//    let leter: String
//    let words: [String: String]
//    
//    init(leter: String, words: [String: String]) {
//        self.leter = leter
//        self.words = words
//        super.init()
//    }
//    
//    override var dictionary: [String: Any]? {
//        get{
//            [leter: words]
//        }
//    }
//    
//}

@propertyWrapper
struct CapitalizedFirst {
    private var value: String = ""

    var wrappedValue: String {
        get { value }
        set { value = newValue.lowercased().prefix(1).capitalized + newValue.lowercased().dropFirst() }
    }

    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }
}



class ZKWord: FireModel, Hashable {
    
    static func == (lhs: ZKWord, rhs: ZKWord) -> Bool {
        return lhs.word == rhs.word
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
    }
    
    
    @CapitalizedFirst var word: String
    
    let meaning: String
    
    init(word: String, meaning: String) {
        self.word = word
        self.meaning = meaning
        super.init()
    }
    
    override init?(dictionary: [String : Any]?) {
        self.word = dictionary?["word"]  as? String ?? ""
        self.meaning = dictionary?["meaning"] as? String ?? ""
        super.init()
    }
    
    override var dictionary: [String: Any]? {
        get{
            [word: meaning]
        }
    }
}

class ZKScore: FireModel {
    
    var name: String = ""
    
    var levelScore: [ZKGameLevel: ZKLevelScore]
    
    init(name: String) {
        self.name = name
        self.levelScore = [ZKGameLevel: ZKLevelScore]()
        for lvl in ZKGameLevel.array {
            let lScore = ZKLevelScore(name: "", points: 0)
            self.levelScore[lvl] = lScore
        }
        super.init()
    }
    
    override init?(dictionary: [String : Any]?) {
        
        guard let dict = dictionary  else { return nil}
        
        self.name = dict["name"] as? String ?? ""
        self.levelScore = [ZKGameLevel: ZKLevelScore]()
        for (key, value) in dict {            
            if key == "name" { continue }
            self.levelScore[ZKGameLevel(rawValue: key)!] = ZKLevelScore(dictionary: value as? [String : Any])
        }
        
        super.init()
    }
    
    override var dictionary: [String: Any]?{
        get{
            
            var dict = [String: Any]()
            dict["name"] = self.name
            for (key, value) in levelScore {
                dict[key.rawValue] = value.dictionary
                
            }
            return dict
        }
    }
}

class ZKLevelScore: FireModel {
        
    var points:  Int
    
    init(name: String, points: Int) {
        self.points = points
        super.init()
    }
    
    override init?(dictionary: [String : Any]?) {
        self.points = dictionary?["points"] as? Int ?? 0
        super.init()
    }
    
    override var dictionary: [String: Any]?{
        get{
            ["points": points]
        }
    }
}
