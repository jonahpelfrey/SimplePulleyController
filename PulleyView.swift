//
//  PulleyView.swift
//  Vault
//
//  Created by Jonah Pelfrey on 9/5/19.
//  Copyright © 2019 Jonah Pelfrey. All rights reserved.
//

import UIKit

class PulleyView: UIView {
    
    public lazy var handle: UIView = {
        let handle = UIView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.backgroundColor = .darkGray
        handle.layer.cornerRadius = 2.5
        return handle
    }()
    
    public lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: 0xEDEDF3)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.layer.backgroundColor = UIColor(hex: 0xEDEDF3).cgColor
        self.roundTopCorners()
        
        self.addSubview(handle)
        NSLayoutConstraint.activate([
            handle.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            handle.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            handle.widthAnchor.constraint(equalToConstant: 40),
            handle.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        self.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 12),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    public func roundTopCorners() {
        self.layer.cornerRadius = 20
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    public func flattenTopCorners() {
        self.layer.cornerRadius = 0
    }
}

