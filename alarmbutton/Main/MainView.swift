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
        addSubview(patrolButton)
        addSubview(cancelButton)
        addSubview(exitButton)
        addSubview(minimizeButton)
        addSubview(testButton)
        addSubview(imagePhoneButton)
        addSubview(textPhoneButton)
        addSubview(segmentedControl)

        errorMessageView.addSubview(errorMessageLabel)
        errorMessageBackgroundView.addSubview(errorMessageView)
        addSubview(errorMessageBackgroundView)

        splashScreen.addSubview(companyLogo)
        addSubview(splashScreen)
    }

    private func setupConstraints() {
        splashScreen.translatesAutoresizingMaskIntoConstraints = false
        splashScreen.topAnchor.constraint(equalTo: topAnchor).isActive = true
        splashScreen.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        splashScreen.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        splashScreen.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        companyLogo.translatesAutoresizingMaskIntoConstraints = false
        companyLogo.centerXAnchor.constraint(equalTo: splashScreen.centerXAnchor).isActive = true
        companyLogo.centerYAnchor.constraint(equalTo: splashScreen.centerYAnchor).isActive = true
        companyLogo.widthAnchor.constraint(equalToConstant: 200).isActive = true
        companyLogo.heightAnchor.constraint(equalToConstant: 200).isActive = true

        errorMessageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        errorMessageBackgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        errorMessageBackgroundView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        errorMessageBackgroundView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        errorMessageBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        errorMessageView.translatesAutoresizingMaskIntoConstraints = false
        errorMessageView.centerYAnchor.constraint(equalTo: errorMessageBackgroundView.centerYAnchor).isActive = true
        errorMessageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        errorMessageView.leftAnchor.constraint(equalTo: errorMessageBackgroundView.leftAnchor).isActive = true
        errorMessageView.rightAnchor.constraint(equalTo: errorMessageBackgroundView.rightAnchor).isActive = true

        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.centerYAnchor.constraint(equalTo: errorMessageView.centerYAnchor).isActive = true
        errorMessageLabel.leftAnchor.constraint(equalTo: errorMessageView.leftAnchor, constant: 16).isActive = true
        errorMessageLabel.rightAnchor.constraint(equalTo: errorMessageView.rightAnchor, constant: -16).isActive = true

        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        exitButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
        exitButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        exitButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.topAnchor.constraint(equalTo: exitButton.bottomAnchor, constant: 8).isActive = true
        segmentedControl.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true

        minimizeButton.translatesAutoresizingMaskIntoConstraints = false
        minimizeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        minimizeButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: 8).isActive = true
        minimizeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        minimizeButton.widthAnchor.constraint(equalToConstant: 110).isActive = true

        testButton.translatesAutoresizingMaskIntoConstraints = false
        testButton.bottomAnchor.constraint(equalTo: minimizeButton.bottomAnchor).isActive = true
        testButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: -8).isActive = true
        testButton.widthAnchor.constraint(equalToConstant: 110).isActive = true
        testButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        textPhoneButton.translatesAutoresizingMaskIntoConstraints = false
        textPhoneButton.bottomAnchor.constraint(equalTo: minimizeButton.bottomAnchor).isActive = true
        textPhoneButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: -8).isActive = true
        textPhoneButton.widthAnchor.constraint(equalToConstant: 110).isActive = true
        textPhoneButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        imagePhoneButton.translatesAutoresizingMaskIntoConstraints = false
        imagePhoneButton.bottomAnchor.constraint(equalTo: minimizeButton.topAnchor, constant: -30).isActive = true
        imagePhoneButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        imagePhoneButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imagePhoneButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        alarmButton.translatesAutoresizingMaskIntoConstraints = false
        alarmButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        alarmButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        alarmButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        alarmButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        patrolButton.translatesAutoresizingMaskIntoConstraints = false
        patrolButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        patrolButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        patrolButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        patrolButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        cancelButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

    // MARK: Views

    let splashScreen: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()

    let companyLogo: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        return imageView
    }()

    let errorMessageBackgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()

    let errorMessageView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()

    let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()

    let segmentedControl: UISegmentedControl = {
        var control = UISegmentedControl(items: ["alert".localized, "patrol".localized])
        control.selectedSegmentIndex = 0

        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        if #available(iOS 13.0, *) {
            control.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            control.selectedSegmentTintColor = .white
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: color], for: .selected)
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        } else {
            control.backgroundColor = .white
            control.tintColor = color
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: color], for: .normal)
        }

        return control
    }()

    let patrolButton: UIButton = {
        var button = UIButton(type: .custom)
        button.adjustsImageWhenHighlighted = false
        let image = UIImage(named: "patrol_button")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.setBackgroundColor(.white, for: .normal)
        return button
    }()

    let alarmButton: UIButton = {
        var button = UIButton(type: .custom)
        button.adjustsImageWhenHighlighted = false
        let image = UIImage(named: "alarm_button")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.setBackgroundColor(.white, for: .normal)
        return button
    }()

    let cancelButton: UIButton = {
        var button = UIButton(type: .custom)
        button.adjustsImageWhenHighlighted = false
        let image = UIImage(named: "cancel_alarm_button")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.setBackgroundColor(.white, for: .normal)
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

    let testButton: InvisibleButton = {
        let button = InvisibleButton(frame: .zero)
        button.setTitle("test".localized.uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 15

        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        button.setBackgroundColor(color.withAlphaComponent(0.3), for: .normal)
        button.setBackgroundColor(color.withAlphaComponent(0.5), for: .highlighted)

        return button
    }()

    let textPhoneButton: InvisibleButton = {
        let button = InvisibleButton(frame: .zero)
        button.setTitle("call".localized.uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 15

        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        button.setBackgroundColor(color.withAlphaComponent(0.3), for: .normal)
        button.setBackgroundColor(color.withAlphaComponent(0.5), for: .highlighted)

        button.isHidden = true
        return button
    }()

    let imagePhoneButton: UIButton = {
        var button = UIButton(frame: .zero)
        button.layer.cornerRadius = 30

        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        button.setBackgroundColor(color.withAlphaComponent(0.3), for: .normal)
        button.setBackgroundColor(color.withAlphaComponent(0.5), for: .highlighted)

        let image = UIImage(named: "phone")
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
        button.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        button.tintColor = .white
        button.contentMode = .center
        return button
    }()

}
