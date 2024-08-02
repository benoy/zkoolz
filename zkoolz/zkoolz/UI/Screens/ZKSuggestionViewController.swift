//
//  ZKSuggestionViewController.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 08/07/24.
//

import UIKit

class ZKSuggestionViewController: ZKBaseViewController {
    
    
    @IBOutlet private weak var wordTxtFld: UITextField!
    @IBOutlet private weak var meaningTxtFld: UITextView!
    @IBOutlet private weak var commentsTxtFld: UITextView!
    
    var viewModel: ZKSuggestionViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
    }
    
    @IBAction private func didTapSuggest(button: UIButton) {
        
        let wrd = wordTxtFld.text ?? ""
        let mng = meaningTxtFld.text ?? ""
        let cmnt = commentsTxtFld.text ?? ""
        viewModel.saveNew(word: wrd, meaning: mng)
    }

}

extension ZKSuggestionViewController: ZKSuggestionViewModelDelegate {
    func shouldShowSaveResult(message: String, isSuccess: Bool) {
        
        if isSuccess {
            self.showOkAlert(message: message)
        } else {
            self.showOkAlert(message: message, titile: "Error")
        }        
    }
    
}
