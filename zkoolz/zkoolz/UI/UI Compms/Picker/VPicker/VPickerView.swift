//
//  VPickerView.swift
//  Survey
//
//  Created by Binoy Vijayan on 17/05/23.
//

import UIKit

class VPickerView: BaseView {

    @IBOutlet private weak var clctnView: UICollectionView!
    var currentCell: PickerCell?
    
    private var selectedIndexPath: IndexPath?
    var selectedIndex =  -1
    var didSelectItem: (String, Int) -> Void = { _ , _ in }
    
    var selectedItem: String = ""
    
    var items: [String] = [String]() {
        didSet {
            
            items.insert("", at: 0)
            if items.count > 1 {
                items.append("")
            }
            
            DispatchQueue.main.async {
                self.clctnView.reloadData()
            }
            
        }
    }
    
    func select(item: String) {
        let idx = items.firstIndex(of: item) ?? 0
        let indexPath = IndexPath(row: idx - 1, section: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.clctnView.scrollToItem(at: indexPath, at: .top, animated: true)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.highlightItem()
        })
        
    }
    
    override func commonInit() {
        Bundle.main.loadNibNamed(VPickerView.nibName , owner: self, options: nil)
        super.commonInit()
        backgroundColor = UIColor.white
        clctnView.register(PickerCell.nib, forCellWithReuseIdentifier: PickerCell.id)
        add(corner: 6, borderColor: .lightGray, borderWidth: 1)
    }
    
    var indexOfCellBeforeDragging: Int = 0
}

extension VPickerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PickerCell.id, for: indexPath) as? PickerCell else {
            return UICollectionViewCell()
        }
        cell.midText = items[indexPath.row]
        return cell
    }
    
    private func highlightItem() {
        let center = convert(clctnView.center, to: clctnView)
        if let index = clctnView.indexPathForItem(at: center) {

            currentCell?.understateLabel()
            let cell: PickerCell? = clctnView.cellForItem(at: index) as? PickerCell
            cell?.highlightLabel()
            currentCell = cell
            selectedItem = items[index.row ]
            selectedIndex = index.row
            didSelectItem(selectedItem, selectedIndex)
        }
    }
}

extension VPickerView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let pageHeight = self.frame.size.height / 3
        let proportionalOffset = clctnView.contentOffset.y / pageHeight
        indexOfCellBeforeDragging = Int(round(proportionalOffset))
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrolling
        targetContentOffset.pointee = scrollView.contentOffset

        // Calculate conditions
        let pageHeight = self.frame.size.height / 3
        let collectionViewItemCount = items.count
        let proportionalOffset = clctnView.contentOffset.y / pageHeight
        let indexOfMajorCell = Int(round(proportionalOffset))
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < collectionViewItemCount && velocity.y > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

        if didUseSwipeToSkipCell {
            // Animate so that swipe is just continued
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = pageHeight * CGFloat(snapToIndex)
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: velocity.y,
                options: .allowUserInteraction,
                animations: {
                    scrollView.contentOffset = CGPoint(x: 0, y: toValue)
                    scrollView.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            // Pop back (against velocity)
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            clctnView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        highlightItem()
    }
    
    
 
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { }
    
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { }
    
   
}

extension VPickerView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ht = (self.frame.size.height / 3)
        let wdth = self.frame.size.width
        return CGSize(width: wdth, height: ht)
    }
}


extension VPickerView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        highlightItem()
    }
}


extension VPickerView: UITextFieldDelegate {
    func textField(_ textField: UITextField, 
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool  {
        
        print(string)
        
        return true
        
    }
}
