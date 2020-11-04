//
//  ControlButton.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 15.04.20.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

import UIKit
import Foundation

enum FlyNavigationButtonId {
    case aircraft
    case start
    case pause
    case resume
    case stop

    var title: String {
        switch self {
            case .aircraft:
                return "Aircraft"
            case .start :
                return "Start"
            case .pause:
                return "Pause"
            case .resume:
                return "Resume"
            case .stop:
                return "Stop"
        }
    }
}

extension FlyNavigationButtonId : CaseIterable {}

class FlyNavigationButton : UIButton {
    // Stored properties
    private(set) var id: FlyNavigationButtonId!

    // Observer properties
    override var isSelected: Bool {
        didSet {
            if isSelected {
                switch self.id! {
                    case .aircraft:
                        backgroundColor = Colors.Overlay.aircraftLocationColor
                    default:
                        break
                }
            } else {
                backgroundColor = Colors.Overlay.primaryColor
            }
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(_ id: FlyNavigationButtonId) {
        self.id = id
        super.init(frame: CGRect())
        setTitle(id.title, for: .normal)
        backgroundColor = Colors.Overlay.primaryColor
        titleLabel!.font = Fonts.titleFont
        clipsToBounds = true
    }
}
