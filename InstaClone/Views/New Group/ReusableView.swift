//
//  ReusableHeader.swift
//  InstaClone
//
//  Created by halil dikişli on 2.05.2023.
//

import UIKit

class ReusableView: UIView {

    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let nibName = "ReusableView"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
}
