//
//  PersonHeaderView.swift
//  SplitCheck
//
//  Created by Neha Mittal on 2/14/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit

class PersonHeaderView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PersonHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
