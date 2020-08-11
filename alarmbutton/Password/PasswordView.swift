//
//  PasswordView.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 22/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit

class PasswordView: UIView {
    
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
        contentView.addSubview(requestLabel)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(tipLabel)
        contentView.addSubview(timeLeftLabel)
        contentView.addSubview(cancelButton)
        contentView.addSubview(proceedButton)
        
        wrapperView.addSubview(contentView)
        scrollView.addSubview(wrapperView)
        
        addSubview(scrollView)
        
        toolbar.setItems([spacer, doneButtonItem], animated: false)
        
        passwordTextField.inputAccessoryView = toolbar
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        wrapperView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        wrapperView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        wrapperView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        wrapperView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        wrapperView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leftAnchor.constraint(equalTo: wrapperView.leftAnchor, constant: 16).isActive = true
        contentView.rightAnchor.constraint(equalTo: wrapperView.rightAnchor, constant: -16).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 320).isActive = true
        contentView.centerYAnchor.constraint(equalTo: wrapperView.centerYAnchor).isActive = true
        
        requestLabel.translatesAutoresizingMaskIntoConstraints = false
        requestLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        requestLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        requestLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.topAnchor.constraint(equalTo: requestLabel.bottomAnchor, constant: 32).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32).isActive = true
        tipLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        tipLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        
        timeLeftLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLeftLabel.topAnchor.constraint(equalTo: tipLabel.bottomAnchor, constant: 8).isActive = true
        timeLeftLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        timeLeftLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: timeLeftLabel.bottomAnchor, constant: 48).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        cancelButton.rightAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -8).isActive = true
        
        proceedButton.translatesAutoresizingMaskIntoConstraints = false
        proceedButton.topAnchor.constraint(equalTo: timeLeftLabel.bottomAnchor, constant: 48).isActive = true
        proceedButton.leftAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 8).isActive = true
        proceedButton.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }
    
    // MARK: Views
    
    let scrollView: UIScrollView = {
        var view = UIScrollView(frame: .zero)
        return view
    }()
    
    let wrapperView: UIView = {
        var view = UIView(frame: .zero)
        return view
    }()
    
    let contentView: UIView = {
        var view = UIView(frame: .zero)
        return view
    }()
    
    let requestLabel: UILabel = {
        var label = UILabel(frame: .zero)
        label.textColor = .contrastTextColor
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = "enter_password_from_sms".localized
        return label
    }()
    
    let passwordTextField: UITextField = {
        var textField = UITextField(frame: .zero)
        textField.backgroundColor = .contrastBackgroundColor
        textField.borderStyle = .roundedRect
        textField.textColor = .defaultTextColor
        textField.placeholder = "password".localized
        
        if #available(iOS 12.0, *) {
            textField.textContentType = .oneTimeCode
        }
        
        return textField
    }()
    
    let tipLabel: UILabel = {
        var label = UILabel(frame: .zero)
        label.textColor = .defaultTextColor
        label.font = label.font.withSize(16)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = "sms_password_tip".localized
        return label
    }()
    
    let timeLeftLabel: UILabel = {
        var label = UILabel(frame: .zero)
        label.isUserInteractionEnabled = false
        label.textColor = .defaultTextColor
        label.font = label.font.withSize(16)
        label.text = "time_left".localized
        return label
    }()
    
    let cancelButton: UIButton = {
        var button = UIButton(frame: .zero)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        button.layer.cornerRadius = 5
        button.setTitle("cancel".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setBackgroundColor(.errorColor, for: .normal)
        return button
    }()
    
    let proceedButton: UIButton = {
        var button = UIButton(frame: .zero)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        button.layer.cornerRadius = 5
        button.setTitle("proceed".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.defaultTextColor, for: .disabled)
        button.setBackgroundColor(.primaryColor, for: .normal)
        button.setBackgroundColor(.primaryColorPale, for: .disabled)
        button.isEnabled = false
        return button
    }()
    

    let doneButtonItem: UIBarButtonItem = {
        var item = UIBarButtonItem(
            title: "done".localized,
            style: .done,
            target: nil,
            action: nil
        )
        return item
    }()
    
    let spacer: UIBarButtonItem = {
        var item = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        return item
    }()
    
    let toolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.tintColor = .primaryColor
        toolbar.isUserInteractionEnabled = true
        toolbar.sizeToFit()
        return toolbar
    }()
    
}
