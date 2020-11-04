//
//  RootView.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 4/25/19.
//  Copyright © 2019 Evgeny Agamirzov. All rights reserved.
//

import UIKit

class FlyView : UIView {
    
    // Computed properties
    private var width: CGFloat {
        return Dimensions.ContentView.width * (Dimensions.ContentView.Ratio.h[0] + Dimensions.ContentView.Ratio.h[1])
               - Dimensions.viewSpacer
    }
    private var height: CGFloat {
        return Dimensions.ContentView.height * Dimensions.ContentView.Ratio.v[0]
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(frame: CGRect(
            x: 0,
            y: 0,
            width: Dimensions.screenWidth,
            height: Dimensions.screenHeight
        ))
        
        addSubview(Environment.flyMapViewController.view)
        addSubview(Environment.consoleViewController.view)
        addSubview(Environment.flyNavigationViewController.view)
        addSubview(Environment.statusViewController.view)
        addSubview(Environment.fpvViewController.view)
        
        let frame = CGRect(
            x: Dimensions.ContentView.x + 60,
            y: Dimensions.ContentView.y,
            width: width - 60,
            height: height
        )
        Environment.statusViewController.view.frame = frame
        
        let frameFPV = CGRect(
            x: 0,
            y: Dimensions.screenHeight * 0.75,
            width: Dimensions.screenWidth * 0.25,
            height: Dimensions.screenHeight * 0.25
        )
        Environment.fpvViewController.view.frame = frameFPV
    }
}
