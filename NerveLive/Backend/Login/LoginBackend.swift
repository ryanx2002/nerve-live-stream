//
//  LoginBackend.swift
//  NerveLive
//
//  Created by wbx on 2023/12/5.
//

import UIKit
import Amplify
import AWSPluginsCore

class LoginBackend: NSObject {
    static let shared = LoginBackend()
    private override init() {

    }

    func signUp(for phone: String,
                password: String,
                needConfirm: @escaping () -> Void,
                suc: @escaping () -> Void,
                fail: @escaping (_ msg: String) -> Void ) {
        let attributes = [
            AuthUserAttribute(.familyName, value: RegisterCache.sharedTools.firstName),
            AuthUserAttribute(.givenName, value: RegisterCache.sharedTools.lastName),
            AuthUserAttribute(.phoneNumber, value: phone)
        ]
        let options = AuthSignUpRequest.Options(userAttributes: attributes)
        print("注册手机号:\(phone), 密码:\(password)")
        Amplify.Auth.signUp(username: phone, password: password, options: options) { result in
            switch result {
            case .success(let signUpResult):
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                    needConfirm()
                } else {
                    print("SignUp Complete")
                    suc()
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
                fail("\(error)")
            }
        }
    }

    func resendCodeForSignUp(username: String,suc:@escaping ()->Void,fail:@escaping (_ msg:String)->Void) {
        Amplify.Auth.resendSignUpCode(for: username){ result in
            switch result {
            case .success:
                print("Confirm signUp succeeded")
                suc()
            case .failure(let error):
                print("An error occurred while confirming sign up \(error)")
                fail("\(error)")
            }
        }
    }

    // confirmSignUp
    func confirmSignUp(for phone: String,
                       with confirmationCode: String,
                       suc: @escaping () -> Void,
                       fail: @escaping (_ msg:String) -> Void) {
        Amplify.Auth.confirmSignUp(for: phone, confirmationCode: confirmationCode) { result in
            switch result {
            case .success:
                print("Confirm signUp succeeded")
                suc()
            case .failure(let error):
                print("An error occurred while confirming sign up \(error)")
                fail("\(error)")
            }
        }
    }

    //  login with userName and password
    public func login(userName: String!,
                      pwd: String!,
                      suc: @escaping ()-> Void,
                      fail: @escaping (_ msg: String) -> Void,
                      confirmSignUp: @escaping () -> Void ) {
        _ = Amplify.Auth.signIn(username: userName, password: pwd) { result in
            do {
                let signinResult = try result.get()
                switch signinResult.nextStep {
                case .confirmSignInWithSMSMFACode(let deliveryDetails, let info):
                    print("SMS code send to \(deliveryDetails.destination)")
                    print("Additional info \(String(describing: info))")

                    // Prompt the user to enter the SMSMFA code they received
                    // Then invoke `confirmSignIn` api with the code

                case .confirmSignInWithCustomChallenge(let info):
                    print("Custom challenge, additional info \(String(describing: info))")

                    // Prompt the user to enter custom challenge answer
                    // Then invoke `confirmSignIn` api with the answer

                case .confirmSignInWithNewPassword(let info):
                    print("New password additional info \(String(describing: info))")

                    // Prompt the user to enter a new password
                    // Then invoke `confirmSignIn` api with new password

                case .resetPassword(let info):
                    print("Reset password additional info \(String(describing: info))")

                    // User needs to reset their password.
                    // Invoke `resetPassword` api to start the reset password
                    // flow, and once reset password flow completes, invoke
                    // `signIn` api to trigger signin flow again.

                case .confirmSignUp(let info):
                    print("Confirm signup additional info \(String(describing: info))")
                    confirmSignUp()
                    // User was not confirmed during the signup process.
                    // Invoke `confirmSignUp` api to confirm the user if
                    // they have the confirmation code. If they do not have the
                    // confirmation code, invoke `resendSignUpCode` to send the
                    // code again.
                    // After the user is confirmed, invoke the `signIn` api again.
                case .done:
                    // Use has successfully signed in to the app
                    print("Sign in succeeded \(result)")
                    self.fetchSession(username: userName, password: pwd,suc: suc, fail: fail)
                }
            } catch {
                print ("Sign in failed \(error)")
                fail("\(error)")
            }
        }
    }

    public func fetchSession(username: String, password: String,suc:@escaping ()->Void,fail:@escaping (_ msg:String)->Void){
        Amplify.Auth.fetchAuthSession { result in
            do {
                let session = try result.get()
                // Get user sub or identity id
                if let identityProvider = session as? AuthCognitoIdentityProvider {
                    let usersub = try identityProvider.getUserSub().get()
                    let identityId = try identityProvider.getIdentityId().get()
                    print("User sub - \(usersub) and identity id \(identityId)")
                    self.fetchUserProfile(phone: username,userId: usersub, suc: suc, fail: fail)
                }else{
                    print("Fetch auth session failed")
                    fail("Fetch auth session failed")
                }
            } catch {
                print("Fetch auth session failed with error - \(error)")
                fail("\(error)")
            }
        }
    }

    public func fetchUserProfile(phone: String?,
                                 userId: String,
                                 suc: @escaping () -> Void,
                                 fail:@escaping (_ msg:String)->Void){
        Amplify.API.query(request: .fetchUserProfile(byId: userId)) {
            event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    guard let postData = try? JSONEncoder().encode(data) else {
                        fail("fetch User Profile Fail");
                        return
                    }
                    guard  let d = try? JSONSerialization.jsonObject(with: postData, options: .mutableContainers) else {
                        fail("fetch User Profile Fail");
                        return
                    }
                    let dic = d as! NSDictionary
                    guard let subDic = dic["getUser"] as? NSDictionary else {
//                        fail("fetch User Profile Fail");
                        self.fetchFirstNameAndLastName(phone: phone, subId: userId, suc: suc, fail: fail)
                        return
                    }
                    LoginTools.sharedTools.saveUserInfo(dic: subDic as! [String : Any])
//                    if let UserContents: NSDictionary = subDic.object(forKey: "UserContents") as? NSDictionary {
//                        if let items: NSArray = UserContents.object(forKey: "items") as? NSArray {
//                            LoginTools.sharedTools.currentUserContents = [UserContent].deserialize(from: items) ?? []
//                        }
//                    }
                    suc();
                    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\(LoginTools.sharedTools.userId())");
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    fail("\(error.errorDescription)");
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
                fail("\(error)");
            }
        }
    }

    func fetchFirstNameAndLastName(phone: String?,
                                   subId: String?,
                                   suc: @escaping () -> Void,
                                   fail: @escaping (_ msg:String) -> Void ){
        Amplify.Auth.fetchUserAttributes() { result in
            switch result {
            case .success(let attributes):
                var firstName = ""
                var lastName = ""
                for item in attributes {
                    if item.key == .familyName {
                        lastName = item.value
                    }
                    if item.key == .givenName {
                        firstName = item.value
                    }
                }
                DispatchQueue.main.async {
                    self.createUserProfile(firstname: firstName, lastname: lastName, phone: phone, subId: subId, suc: suc, fail: fail)
                }
            case .failure(let error):
//                DispatchQueue.main.async {
//                    self.hub?.hide(animated: true)
//                }
                fail("\(error)")
                print("Fetching user attributes failed with error \(error)")
            }
        }
    }
    func createUserProfile(firstname: String?,
                           lastname: String?,
                           phone: String?,
                           subId: String?,
                           suc: @escaping () -> Void,
                           fail: @escaping (_ msg:String) -> Void ) {
        Amplify.API.mutate(request: .createProfile(subId: subId ?? "", firstName: firstname ?? "", lastName: lastname ?? "", phone: phone ?? "")){
            event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    guard let postData = try? JSONEncoder().encode(data) else {
                        fail("Failed")
                        return
                    }
                    guard  let d = try? JSONSerialization.jsonObject(with: postData, options: .mutableContainers) else {
                        fail("Failed")
                        return
                    }
                    let dic = d as! NSDictionary
                    if let subDic = dic["createUser"] as? NSDictionary {
                        print("\(subDic)")
                        LoginTools.sharedTools.saveUserInfo(dic: subDic as! [String : Any])
                        suc();
                        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\(LoginTools.sharedTools.userId())");
                        suc()
                    }else {
                        fail("Failed")
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    fail("\(error.errorDescription)")
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
                fail("\(error)")
            }
        }
    }
}

