//
//  ZKAPIManager.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 18/06/24.
//

import Foundation

protocol ZKAPIManageable {
    func getInfo(for word: String) async -> ZKWord?
}

class ZKAPIManager: ZKAPIManageable {
    
    private var httpClient: ZKHttpClientProtocol!
    
    private let dictionaryUrl = "https://api.dictionaryapi.dev/api/v2/entries/en/"
    
    init(httpClient: ZKHttpClientProtocol = ZKHttpClient()) {
        self.httpClient = httpClient
    }
    
    func getInfo(for word: String) async -> ZKWord? {
        
        let urlStr = dictionaryUrl + word
        let result  = await httpClient.get(usrlString: urlStr)
        
        if let data = result.0 {
            do {
                let words = try JSONDecoder().decode([ZKDictionaryWord].self, from: data)
                let dictionaryWord = words[0]
                let meaning = dictionaryWord.meanings[0].definitions[0].definition
                let wordObject = ZKWord(word: word, meaning: meaning)
                return wordObject
            } catch {
                print(error.localizedDescription)
                return nil
            }
        
           
            
        }
        
        return nil
    }
    
}
