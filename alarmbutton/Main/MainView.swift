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
        addSubview(exitButton)
        addSubview(minimizeButton)
    }

    private func setupConstraints() {
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        exitButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
        exitButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        exitButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        minimizeButton.translatesAutoresizingMaskIntoConstraints = false
        minimizeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        minimizeButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        minimizeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        minimizeButton.widthAnchor.constraint(equalToConstant: 110).isActive = true

        alarmButton.translatesAutoresizingMaskIntoConstraints = false
        alarmButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        alarmButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        alarmButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        alarmButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        cancelButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
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

    let exitButton: UIButton = {
        var button = UIButton(frame: .zero)
        button.layer.cornerRadius = 30

        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        button.setBackgroundColor(color.withAlphaComponent(0.3), for: .normal)
        button.setBackgroundColor(color.withAlphaComponent(0.5), for: .highlighted)

        let image = UIImage(named: "exit")
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
        button.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 15, right: 15)

        return button
    }()

    let minimizeButton: InvisibleButton = {
        let button = InvisibleButton(frame: .zero)
        button.setTitle("minimize".localized.uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 15

        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        button.setBackgroundColor(color.withAlphaComponent(0.3), for: .normal)
        button.setBackgroundColor(color.withAlphaComponent(0.5), for: .highlighted)

        return button
    }()

}
