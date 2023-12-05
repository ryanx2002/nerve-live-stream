//
//  PhoneInputViewController.swift
//  Nerve
//
//  Created by 殷聃 on 2023/9/9.
//

import UIKit

class PhoneInputViewController: BaseViewController {
    @IBOutlet weak var DescTitle:UILabel!
    @IBOutlet weak var CountryCodeInputText:UITextField!
    @IBOutlet weak var PhoneNumberInputText:UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.DescTitle.attributedText = StringUtils.TextWithBorder(font: 20, text: "What’s your phone number?")
        self.CountryCodeInputText.attributedPlaceholder = StringUtils.PlaceholderAttributeText(contentText: "+1")
        self.CountryCodeInputText.delegate = self;
        self.PhoneNumberInputText.attributedPlaceholder = StringUtils.PlaceholderAttributeText(contentText: "(610)555-0123")
        self.PhoneNumberInputText.delegate = self

//        VerificationCodeManager.shared.getVerificationCode(for: "+8618538069868")
    }
}

extension PhoneInputViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(!StringUtils.isBlank(value: self.CountryCodeInputText.text) &&
           !StringUtils.isBlank(value: self.PhoneNumberInputText.text)) {
            RegisterCache.sharedTools.countryCode = CountryCodeInputText.text ?? ""
            RegisterCache.sharedTools.phone = PhoneNumberInputText.text ?? ""
            let vc = ConfirmationCodeViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        textField.resignFirstResponder()
        return true
    }
}
