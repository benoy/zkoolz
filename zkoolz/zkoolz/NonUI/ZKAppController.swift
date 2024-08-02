//
//  ZKAppController.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 14/06/24.
//

import Foundation
import UIKit

class ZKAppController {
    
    weak var window: UIWindow!
    
    private var navController: UINavigationController!
    

    static let shared = ZKAppController()
    private init() {}
    
    func initialise(with window: UIWindow) {
        self.window = window
        self.window.makeKeyAndVisible()
        showFirstScreen()
       
    }
    
    func showFirstScreen() {
        
        
        
        if ZKDBManager.getUserAuthId().isEmpty {
            let vc = ZKLoginViewController.instance
            navController = UINavigationController(rootViewController: vc)
        } else {
            let vm = ZKHomeViewModel()
            let vc = ZKHomeViewController.instance
            vc.viewModel = vm
            navController = UINavigationController(rootViewController: vc)
        }
        
        
        window.rootViewController = navController
        
//        let dbm = ZKDBManager()
//        dbm.bulkUpdate()
        
//        var temp = [String: [String]]()
//        for (key, val) in  countryPhoneCodes {
//            
//            temp[val, default: [String]()].append(key)
//        }
//        
//        print("\(temp)")
    }
    
    func showLoginScreen() {
        let vc = ZKLoginViewController.instance
        navController.pushViewController(vc, animated: true)
    }
    
    func showHomeScreen() {
        
        let vm = ZKHomeViewModel()
        let vc = ZKHomeViewController.instance
        vc.viewModel = vm
        navController.pushViewController(vc, animated: true)
    }
    
    func showGameScreen(for level: ZKGameLevel) {
        
        let engine = ZKGemeEngine(level: level)
        let vm = ZKGameViewModel(gameEngine: engine)
        
        let vc = ZKGameViewController.instance
        vc.viewModel = vm
        navController.pushViewController(vc, animated: true)
    }
    
    func showSuggestionScreen() {
        let vc = ZKSuggestionViewController .instance
        vc.viewModel = ZKSuggestionViewModel()
        navController.pushViewController(vc, animated: true)
    }
}
