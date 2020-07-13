//
//  MainView.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 26/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit

class MainView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .defaultBackgroundColor
        
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        addSubview(alarmButton)
        addSubview(cancelButton)
    }
    
    private func setupConstraints() {
        alarmButton.translatesAutoresizingMaskIntoConstraints = false
        alarmButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        alarmButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        alarmButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        alarmButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        cancelButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    }
    
    // MARK: Views
    
    let alarmButton: UIButton = {
        var button = UIButton(frame: .zero)
        button.setTitle("alarm".localized.uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setBackgroundColor(.errorColor, for: .normal)
        return button
    }()
    
    let cancelButton: UIButton = {
        var button = UIButton(frame: .zero)
        button.setTitle("cancel_alarm".localized.uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setBackgroundColor(.secondaryColor, for: .normal)
        button.isHidden = true
        return button
    }()
    
}