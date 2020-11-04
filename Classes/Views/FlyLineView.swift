//
//  RootView.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 4/25/19.
//  Copyright © 2019 Evgeny Agamirzov. All rights reserved.
//

import UIKit

class FlyLineView : UIView {
    
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
        addSubview(Environment.mapViewController.view)
        //addSubview(Environment.consoleViewController.view)
        addSubview(Environment.missionViewController.view)
        addSubview(Environment.navigationViewController.view)
        //addSubview(Environment.statusViewController.view)
        //let frameStatus = CGRect(
        //    x: Dimensions.ContentView.x,
        //    y: Dimensions.ContentView.y,
        //    width: width,
        //    height: height
        //)
        //Environment.statusViewController.view.frame = frameStatus
    }
}

extension FlyLineView {
    //将当前视图转为UIImage
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func screenSnapshot() -> UIImage? {
        guard frame.size.height > 0 && frame.size.width > 0 else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
