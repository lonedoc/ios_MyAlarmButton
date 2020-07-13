//
//  LoginView.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 01/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit

class LoginView : UIView {
 
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
        contentView.addSubview(cityLabel)
        contentView.addSubview(cityTextField)
        contentView.addSubview(companyLabel)
        contentView.addSubview(companyTextField)
        contentView.addSubview(phoneLabel)
        contentView.addSubview(countryCodeTextField)
        contentView.addSubview(phoneTextField)
        contentView.addSubview(submitButton)
        
        wrapperView.addSubview(contentView)
        scrollView.addSubview(wrapperView)
        
        addSubview(scrollView)
        
        toolbar.setItems([prevButtonItem, gap, nextButtonItem, spacer, doneButtonItem], animated: false)
        
        cityTextField.inputView = cityPicker
        companyTextField.inputView = companyPicker
        countryCodeTextField.inputView = countryCodePicker
        
        cityTextField.inputAccessoryView = toolbar
        companyTextField.inputAccessoryView = toolbar
        countryCodeTextField.inputAccessoryView = toolbar
        phoneTextField.inputAccessoryView = toolbar
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
        contentView.heightAnchor.constraint(equalToConstant: 330).isActive = true
        contentView.centerYAnchor.constraint(equalTo: wrapperView.centerYAnchor).isActive = true
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        cityLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        cityLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

        cityTextField.translatesAutoresizingMaskIntoConstraints = false
        cityTextField.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 8).isActive = true
        cityTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        cityTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

        companyLabel.translatesAutoresizingMaskIntoConstraints = false
        companyLabel.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 16).isActive = true
        companyLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        companyLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

        companyTextField.translatesAutoresizingMaskIntoConstraints = false
        companyTextField.topAnchor.constraint(equalTo: companyLabel.bottomAnchor, constant: 8).isActive = true
        companyTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        companyTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.topAnchor.constraint(equalTo: companyTextField.bottomAnchor, constant: 16).isActive = true
        phoneLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        phoneLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        
        countryCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        countryCodeTextField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 8).isActive = true
        countryCodeTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        countryCodeTextField.widthAnchor.constraint(equalToConstant: 64).isActive = true

        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        phoneTextField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 8).isActive = true
        phoneTextField.leftAnchor.constraint(equalTo: countryCodeTextField.rightAnchor, constant: 8).isActive = true
        phoneTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 64).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
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
    
    let cityLabel: UILabel = {
        var label = UILabel(frame: .zero)
        label.textColor = .contrastTextColor
        label.text = "pick_city".localized
        return label
    }()
    
    let cityTextField: UITextField = {
        var textField = UITextField(frame: .zero)
        textField.backgroundColor = .contrastBackgroundColor
        textField.borderStyle = .roundedRect
        textField.textColor = .defaultTextColor
        return textField
    }()
    
    let companyLabel: UILabel = {
        var label = UILabel(frame: .zero)
        label.textColor = .contrastTextColor
        label.text = "pick_company".localized
        return label
    }()
    
    let companyTextField: UITextField = {
        var textField = UITextField(frame: .zero)
        textField.backgroundColor = .contrastBackgroundColor
        textField.borderStyle = .roundedRect
        textField.textColor = .defaultTextColor
        return textField
    }()
    
    let phoneLabel: UILabel = {
        var label = UILabel(frame: .zero)
        label.textColor = .contrastTextColor
        label.text = "enter_phone_number".localized
        return label
    }()
    
    let countryCodeTextField: UITextField = {
        var textField = UITextField(frame: .zero)
        textField.backgroundColor = .contrastBackgroundColor
        textField.borderStyle = .roundedRect
        textField.textColor = .defaultTextColor
        return textField
    }()
    
    let phoneTextField: UITextField = {
        var textField = UITextField(frame: .zero)
        textField.backgroundColor = .contrastBackgroundColor
        textField.borderStyle = .roundedRect
        textField.textColor = .defaultTextColor
        textField.keyboardType = .phonePad
        return textField
    }()
    
    let submitButton: UIButton = {
        var button = UIButton(frame: .zero)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        button.layer.cornerRadius = 5
        button.setTitle("get_pass_code".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.defaultTextColor, for: .disabled)
        button.setBackgroundColor(.primaryColor, for: .normal)
        button.setBackgroundColor(.primaryColorPale, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    let cityPicker: UIPickerView = {
        var picker = UIPickerView(frame: .zero)
        return picker
    }()
    
    let companyPicker: UIPickerView = {
        var picker = UIPickerView(frame: .zero)
        return picker
    }()
    
    let countryCodePicker: UIPickerView = {
        var picker = UIPickerView(frame: .zero)
        return picker
    }()
    
    let prevButtonItem: UIBarButtonItem = {
        var item = UIBarButtonItem(
            image: UIImage(named: "left_angle_arrow"),
            style: .plain,
            target: nil,
            action: nil
        )
        return item
    }()
    
    let nextButtonItem: UIBarButtonItem = {
        var item = UIBarButtonItem(
            image: UIImage(named: "right_angle_arrow"),
            style: .plain,
            target: nil,
            action: nil
        )
        return item
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
    
    let gap: UIBarButtonItem = {
        let item = UIBarButtonItem(
            barButtonSystemItem: .fixedSpace,
            target: nil,
            action: nil
        )
        item.width = 15
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
