//
//  ControlButtonsView.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 14.04.20.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

import UIKit

class FlyNavigationView : UIView {
    // Static properties
    static let width = Dimensions.ContentView.width * Dimensions.ContentView.Ratio.h[2]

    // Stored properties
    private let stackView = UIStackView()
    private var buttons: [FlyNavigationButton] = []

    // Computed properties
    private var xOffset: CGFloat {
        return Dimensions.ContentView.width * (Dimensions.ContentView.Ratio.h[0] + Dimensions.ContentView.Ratio.h[1])
    }
    private var buttonHeight: CGFloat {
        return Dimensions.ContentView.height * Dimensions.ContentView.Ratio.v[0]
    }
    private var height: CGFloat {
        return buttonHeight * CGFloat(FlyNavigationButtonId.allCases.count)
               + Dimensions.viewSpacer * CGFloat(FlyNavigationButtonId.allCases.count - 1)
    }

    // Notifyer properties
    var buttonSelected: ((_ id: FlyNavigationButtonId, _ isSelected: Bool) -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(frame: CGRect())
        frame = CGRect(
            x: Dimensions.ContentView.x + xOffset,
            y: Dimensions.ContentView.y,
            width: NavigationView.width,
            height: height
        )

        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = Dimensions.viewSpacer

        for id in FlyNavigationButtonId.allCases {
            buttons.append(FlyNavigationButton(id))
            buttons.last!.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
            NSLayoutConstraint.activate([
                buttons.last!.heightAnchor.constraint(equalToConstant: buttonHeight),
                buttons.last!.widthAnchor.constraint(equalToConstant: NavigationView.width)
            ])
            stackView.addArrangedSubview(buttons.last!)
        }

        stackView.translatesAutoresizingMaskIntoConstraints = false;
        addSubview(stackView)
    }
}

// Public methods
extension FlyNavigationView {
    func deselectButton(with id: FlyNavigationButtonId) {
        for button in buttons {
            if button.id == id {
                button.isSelected = false
            }
        }
    }
}

// Handle control events
extension FlyNavigationView {
    @objc func onButtonPressed(_ sender: FlyNavigationButton) {
        sender.isSelected = !sender.isSelected
        buttonSelected?(sender.id, sender.isSelected)
    }
}
