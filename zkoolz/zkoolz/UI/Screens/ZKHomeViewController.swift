//
//  ZKHomeViewController.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 14/06/24.
//

import UIKit

import GoogleMobileAds

class ZKHomeViewController: ZKBaseViewController {
    
    
    @IBOutlet private weak var tableVIew: UITableView!
    
    var viewModel: ZKHomeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let xib = UINib(nibName: ZKHomeCell.id, bundle: Bundle(for: ZKHomeCell.self))
        tableVIew.register(xib, forCellReuseIdentifier: ZKHomeCell.id)
    }
    
    private func showGameScreen(_ level: Int) {
        
        ZKAppController.shared.showGameScreen(for: viewModel.level(at: level))
    }
    
    
}

extension ZKHomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.rowsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ZKHomeCell.id) as? ZKHomeCell else { return UITableViewCell()
        }
        cell.cellTitle = viewModel.item(at: indexPath.section)
        cell.imageName = viewModel.item(at: indexPath.section)
        
        return cell
    }
}

extension ZKHomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        showGameScreen(indexPath.section)
    }
}
