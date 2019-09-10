//
//  PulleyContainerViewController.swift
//  Vault
//
//  Created by Jonah Pelfrey on 9/10/19.
//  Copyright © 2019 Jonah Pelfrey. All rights reserved.
//

import UIKit

public enum DrawerPanDirection: String {
    case up
    case down
}

public enum DrawerPosition: String {
    case expanded
    case collapsed
}

protocol PulleyMainViewControllerDelegate: class {
    func expandedAnchorForDrawer() -> NSLayoutYAxisAnchor
}

protocol PulleyDrawerViewControllerDelegate: class {
    func collapsedAnchorForDrawer() -> NSLayoutYAxisAnchor
}

class PulleyContainerViewController: UIViewController {
    
    weak var mainDelegate: PulleyMainViewControllerDelegate?
    weak var drawerDelegate: PulleyDrawerViewControllerDelegate?
    
    private let mainViewController: UIViewController
    private let drawerViewController: UIViewController
    
    private lazy var drawerContainerView: PulleyView = {
        let pulley = PulleyView()
        pulley.translatesAutoresizingMaskIntoConstraints = false
        return pulley
    }()
    
    private var drawerActiveConstraint: NSLayoutConstraint!
    private var originalDrawerConstant: CGFloat = 0
    private var currentPanDirection: DrawerPanDirection = .up
    private var currentRestingPosition: DrawerPosition = .collapsed
    private let panRecognizer = UIPanGestureRecognizer()
    
    required init(main: UIViewController, drawer: UIViewController) {
        self.mainViewController = main
        self.drawerViewController = drawer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        setupMainViewController()
        setupDrawerViewContainer()
        setupDrawerViewActiveConstraint()
        setupDrawerViewController()
        setupGestures()
    }
    
    /* Collapsed Anchor */
    private func collapsedAnchorForDrawer() -> NSLayoutYAxisAnchor {
        if let delegate = drawerDelegate {
            return delegate.collapsedAnchorForDrawer()
        } else {
            return self.view.centerYAnchor
        }
    }
    
    /* Expanded Anchor */
    private func expandedAnchorForDrawer() -> NSLayoutYAxisAnchor {
        if let delegate = mainDelegate {
            return delegate.expandedAnchorForDrawer()
        } else {
            return self.view.safeAreaLayoutGuide.topAnchor
        }
    }
    
    /* Main View Controller */
    private func setupMainViewController() {
        addChild(mainViewController)
        view.addSubview(mainViewController.view)
        mainViewController.view.frame = view.frame
        mainViewController.didMove(toParent: self)
    }
    
    /* Drawer View Container */
    private func setupDrawerViewContainer() {
        self.view.addSubview(drawerContainerView)
        NSLayoutConstraint.activate([
            drawerContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            drawerContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            drawerContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
            ])
    }
    
    /* Drawer View Container Active Constraint */
    private func setupDrawerViewActiveConstraint() {
        drawerActiveConstraint = drawerContainerView.topAnchor.constraint(equalTo: collapsedAnchorForDrawer())
        drawerActiveConstraint.isActive = true
    }
    
    /* Drawer View Controller */
    private func setupDrawerViewController() {
        drawerViewController.beginAppearanceTransition(true, animated: false)
        addChild(drawerViewController)
        drawerContainerView.addSubview(drawerViewController.view)
        drawerViewController.view.constrainTo(drawerContainerView.contentView)
        drawerViewController.didMove(toParent: self)
        drawerViewController.endAppearanceTransition()
    }
    
    /* Drawer Controller Gestures */
    private func setupGestures() {
        panRecognizer.addTarget(self, action: #selector(didPan))
        drawerContainerView.addGestureRecognizer(panRecognizer)
    }
    
    /* Handle Pan Gesture Recognition */
    @objc private func didPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began: break
        case .changed:
            
            if recognizer.translation(in: self.view).y > 0 {
                currentPanDirection = .down
            } else { currentPanDirection = .up }
            
            let translation = recognizer.translation(in: self.view)
            drawerActiveConstraint.isActive = false
            drawerActiveConstraint.constant += translation.y
            drawerActiveConstraint.isActive = true
            self.view.layoutIfNeeded()
            
            recognizer.setTranslation(CGPoint.zero, in: self.view)
            
        case .ended, .cancelled:
            
            drawerActiveConstraint.isActive = false
            
            switch currentPanDirection {
            case .up:
                drawerActiveConstraint = drawerContainerView.topAnchor.constraint(equalTo: expandedAnchorForDrawer())
                drawerContainerView.flattenTopCorners()
            case .down:
                drawerActiveConstraint = drawerContainerView.topAnchor.constraint(equalTo: collapsedAnchorForDrawer())
                drawerContainerView.roundTopCorners()
            }
            
            drawerActiveConstraint.constant = originalDrawerConstant
            drawerActiveConstraint.isActive = true
            
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.4,
                options: [],
                animations: { [weak self] in
                    self?.view.layoutIfNeeded()
                },
                completion: nil
            )
            
        default: break
        }
    }
}

