//
//  ZKSuggestionViewModel.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 14/07/24.
//

import Foundation

protocol ZKSuggestionViewModelDelegate {
    
    func shouldShowSaveResult(message: String, isSuccess: Bool)
    
}

class ZKSuggestionViewModel {
    
    var delegate: ZKSuggestionViewModelDelegate!
    var dbManager: ZKDBManageable!
    
    init(dbManager: ZKDBManageable = ZKDBManager()) {
        self.dbManager = dbManager
    }
    
    func saveNew(word: String, meaning: String) {
        
        if word.isEmpty || meaning.isEmpty {
            delegate.shouldShowSaveResult(message: "Word and meaning fields should not be empty.", 
                                          isSuccess: false)
        } else {
            let wrd = ZKWord(word: word, meaning: meaning)
            Task { [weak self] in
                guard let self = self else { return  }
                let result = await self.dbManager.saveSuggestion(word: wrd)
                
                if !result {
                    self.delegate.shouldShowSaveResult(message: "Unknown error, couldnot add the word into suggestion list.",
                                                       isSuccess: result)
                } else {
                    self.delegate.shouldShowSaveResult(message: "The word '\(word)' has been added to the sugggestion list, our team will review the same and will add to the database.",
                                                       isSuccess: result)
                }
            }
        }
    }
}
