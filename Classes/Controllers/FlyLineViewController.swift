//
//  RootViewController.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 4/24/19.
//  Copyright © 2019 Evgeny Agamirzov. All rights reserved.
//

import UIKit

class FlyLineViewController : UIViewController {
    var rootView: FlyLineView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // call by programm init
    init() {
        super.init(nibName: nil, bundle: nil)
        setUp()
    }
    
    func setUp() {
        rootView = FlyLineView()
        view = rootView
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        button.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    // call by storyboard init
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    @objc func handleBack(button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
