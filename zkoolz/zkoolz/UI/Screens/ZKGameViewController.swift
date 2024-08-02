//
//  ZKGameViewController.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 15/06/24.
//

import UIKit
import GoogleMobileAds
import UserMessagingPlatform

class ZKGameViewController: ZKBaseViewController {

    var viewModel: ZKGameViewModel!
    
    @IBOutlet private weak var autoWordLabel: UILabel!
    @IBOutlet private weak var autoMeaningLabel: UILabel!
    @IBOutlet private weak var lastLetterLabel: UILabel!
    @IBOutlet private weak var levelTitle: UILabel!
    @IBOutlet private weak var wordTxtField: UITextField!
    @IBOutlet private weak var countdownLabel: UILabel!
    @IBOutlet private weak var wordCountLabel: UILabel!
    @IBOutlet private weak var currentPointsLabel: UILabel!
    @IBOutlet private weak var totalScoreLabel: UILabel!
    @IBOutlet private weak var levelIconView: UIImageView!
    
    
    @IBOutlet private weak var autoWordContanerView: UIView!
    @IBOutlet private weak var autoWordContanerLft: NSLayoutConstraint!
    
    private let overlay = ZKOverlayView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideAutoWord()
        levelTitle.text = viewModel.levelTitle
        levelIconView.image = UIImage(named: viewModel.levelTitle)
        countdownLabel.layer.cornerRadius = 25
        countdownLabel.clipsToBounds = true
        loadGame()
        
    }
    
    func loadGame() {
        viewModel.start()
        viewModel.delegate = self
        Task {
            let word = await viewModel.randomWord
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.showAutoWord(word)
                
            })
        }
    }
    
    func showAutoWord(_ word: ZKWord?) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.autoWordContanerView.isHidden = false
            UIView.animate(withDuration: 1, animations: {
                self.autoWordContanerLft.constant = 16
                self.view.layoutIfNeeded()
                self.updateUIWithNew(word: word)
            })
            
        })
        
    }
    
    func hideAutoWord() {
        
        UIView.animate(withDuration: 1, animations: {
            self.autoWordContanerView.isHidden = true
            
        })
        self.autoWordContanerLft.constant = UIScreen.main.bounds.size.width * -1
    }
    
    private func updateUIWithNew(word: ZKWord?) {
        
        DispatchQueue.main.async {
            self.autoWordLabel.text = word?.word.uppercased() ?? ""
            self.autoMeaningLabel.text = word?.meaning ?? ""
            self.lastLetterLabel.text = self.viewModel.lastLetterMessage
            self.wordTxtField.text = ""
            self.wordCountLabel.text = self.viewModel.wordCountString
            self.currentPointsLabel.text = self.viewModel.pointsString
            self.totalScoreLabel.text = self.viewModel.totalScoreString
        }
    }

    @IBAction private func didTapSubmit(button: UIButton) {
        validateCounterWord()
    }
    
    @IBAction private func didTapSuggest(button: UIButton) {
        ZKAppController.shared.showSuggestionScreen()
    }
    
    private func validateCounterWord() {
        let word = wordTxtField.text ?? ""
        Task {
            let reuslt = await viewModel.validate(word: word)
            
            
            if reuslt.0 == nil{
                DispatchQueue.main.async {
                    self.countdownLabel.text = ""
                }
                self.hideAutoWord()
                self.showNextWord()
            } else {
                showOkAlert(message: reuslt.1)
                
                
                DispatchQueue.main.async {
                    self.wordTxtField.text = ""
                }
            }
        }
    }
    
    private func showNextWord()  {
        Task {
            let word = await viewModel.nextWord
            DispatchQueue.main.async {
                self.updateUIWithNew(word: word)
                self.showAutoWord(word)
            }
        }
        
    }
    
    private func showAdConsent() {
        
        /*
        ZKAdConsentManager.shared.presentPrivacyOptionsForm(from: self) {
            [weak self] formError in
            guard let self else { return }
            guard let formError else { return  }
            
            print(formError.localizedDescription)
            
            let alertController = UIAlertController(
                title: formError.localizedDescription, message: "Please try again later.",
                preferredStyle: .alert)
            alertController.addAction(
                UIAlertAction(
                    title: "OK", style: .cancel,
                    handler: { _ in
                        
                    }))
            self.present(alertController, animated: true)
        }
         */
    }
}


extension ZKGameViewController: ZKGameViewModelDelegate {
    
    func shouldUpdate(countdown: Int) {
        DispatchQueue.main.async {
            self.countdownLabel.text = "\(countdown)"
        }
    }
    
    func shouldStopCountdown() {
        countdownLabel.text = ""
    }
    
    func didReachTimeLimit() {
        showNextWord()
    }
    
    func didFInishLevel(point: Int) {

        viewModel.updateScore()
        showInterstitial() { [weak self] in
            
            DispatchQueue.main.async {
                self?.showYesNoAlert(message: self?.viewModel.levelFishMessage ?? "", callback: { yesNo in
                    if yesNo {
                        self?.loadGame()
                    } else {
                        self?.popViewController()
                    }
                })
            }
        }
    }
    
    func shouuldUpdateTotal() {
        DispatchQueue.main.async {
            self.totalScoreLabel.text = self.viewModel.totalScoreString
        }
    }
    
    func didSuggestWord(mesasge: String, isSuccess: Bool) {
        self.showOkAlert(message: mesasge)
    }
    
}
