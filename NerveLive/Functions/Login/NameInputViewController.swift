//
//  NameInputViewController.swift
//  Nerve
//
//  Created by 殷聃 on 2023/9/9.
//

import UIKit
import SVProgressHUD

class NameInputViewController: BaseViewController{

    @IBOutlet weak var DescTitle:UILabel!
    @IBOutlet weak var FisrtNameInputText:UITextField!
    @IBOutlet weak var LastNameInputText:UITextField!
    var firstName:String?
    var lastName:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.DescTitle.attributedText = StringUtils.TextWithBorder(font: 20, text: "What’s your first name?")
        // Do any additional setup after loading the view.
        let firstnameText = NSAttributedString(string: "First name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexColorWithAlpha(color: "#A9A9A9", alpha: 1)])

        self.FisrtNameInputText.attributedPlaceholder = firstnameText
        self.FisrtNameInputText.delegate = self;
        self.FisrtNameInputText.textContentType = .givenName
        self.FisrtNameInputText.becomeFirstResponder()

        let lastnameText = NSAttributedString(string: "Last name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.hexColorWithAlpha(color: "#A9A9A9", alpha: 1)])

        self.LastNameInputText.attributedPlaceholder = lastnameText
        self.LastNameInputText.delegate = self
        self.LastNameInputText.textContentType = .familyName
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NameInputViewController:UITextFieldDelegate{
    
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            goNextPage()
            textField.resignFirstResponder()
            return true
        }
    
    func goNextPage(){
        if(!StringUtils.isBlank(value: self.FisrtNameInputText.text)
           &&
           StringUtils.isBlank(value: self.LastNameInputText.text) && self.FisrtNameInputText.isFirstResponder){
            self.LastNameInputText.becomeFirstResponder()
            
        }
        else if(!StringUtils.isBlank(value: self.FisrtNameInputText.text)
           &&
           !StringUtils.isBlank(value: self.LastNameInputText.text)){
            RegisterCache.sharedTools.firstName = self.FisrtNameInputText.text ?? "";
            RegisterCache.sharedTools.lastName = self.LastNameInputText.text ?? "";
            var user = LoginTools.sharedTools.userInfo()
            user.firstName = RegisterCache.sharedTools.firstName
            user.lastName = RegisterCache.sharedTools.lastName
            SVProgressHUD.show()
            LoginBackend.shared.updateUser(user: user) {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    getAppDelegate().changeRootViewController()
                }
            } fail: { msg in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: msg)
                }
            }
        }
    }
}
