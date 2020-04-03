//
//  LoginViewController.swift
//  MyController
//
//  Created by Swiftpy on 01/04/2020.
//  Copyright © 2020 Swiftpy. All rights reserved.
//

import UIKit
import JGProgressHUD
import NMSSH

class LoginViewController: UIViewController {
    var session: NMSSHSession!
    let hud = JGProgressHUD(style: .dark)
    let semaphore = DispatchSemaphore(value: 0)
    let uDefault = UserDefaults.standard
    @IBOutlet weak var host_textfield: UITextField!
    @IBOutlet weak var username_textfield: UITextField!
    @IBOutlet weak var password_textfield: UITextField!
    @IBOutlet weak var sshLabel: UILabel!
    
    var yourUsername: String?
    var yourLocalAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        host_textfield.text = uDefault.string(forKey: "current_host")
        username_textfield.text = uDefault.string(forKey: "current_hostname")
        password_textfield.text = uDefault.string(forKey: "current_password")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        uDefault.set(host_textfield.text, forKey: "current_host")
        uDefault.set(username_textfield.text, forKey: "current_hostname")
        uDefault.set(password_textfield.text, forKey: "current_password")
    }
    @IBAction func connect_action(_ sender: Any) {
        if(password_textfield.text == "" || host_textfield.text == "" || username_textfield.text == ""){
            wrongEntryAlert(title: "Missed camp", message: "You must enter all needed camps")
        }
        else{
            createLoadAnimation()
        }
        
    }
    func wrongEntryAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: {
                self.password_textfield.textColor = .red
                self.username_textfield.textColor = .red
                self.host_textfield.textColor = .red
            })
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createLoadAnimation(){
        NuovoThread(input_hostname: self.host_textfield.text!, input_username: self.username_textfield.text!, input_password: self.password_textfield.text!);
        DispatchQueue.main.async {
            let indicator = JGProgressHUDIndeterminateIndicatorView()
            self.hud.indicatorView = indicator
            self.hud.textLabel.text = "Connecting..."
            self.hud.show(in: self.view)
        }
    }
    func NuovoThread(input_hostname: String, input_username: String, input_password: String){
        DispatchQueue.global().async(qos: .userInitiated) {
            let ssh = SSHManager()
            ssh.SSHConnect(hostname: input_hostname, username: input_username, password: input_password)
            self.session = ssh.session
            self.successOrErrorToPresent(condition: self.session.isAuthorized);
        }
    }
    func successOrErrorToPresent(condition: Bool){
        DispatchQueue.main.async {
            let hud = JGProgressHUD(style: .dark)
            if(condition){
                let indicator = JGProgressHUDSuccessIndicatorView()
                hud.indicatorView = indicator
                hud.textLabel.text = "Connected"
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 1.5)
                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: {_ in
                    self.performSegue(withIdentifier: "login", sender: LoginViewController.self )
                })
            }
            else{
                let indicator = JGProgressHUDErrorIndicatorView()
                hud.indicatorView = indicator
                hud.textLabel.text = "Connection Lost"
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 1.5)
            }
            self.hud.dismiss()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewController
        vc.input_host = host_textfield.text
        vc.input_password = password_textfield.text
        vc.input_username = username_textfield.text
        vc.session = session
    }
}

extension JGProgressHUDAnimation{
    func animationFinished(timer: Float, view: UIView){
        Timer.scheduledTimer(withTimeInterval: TimeInterval(timer), repeats: false, block: {_ in
            let hud = JGProgressHUD(style: .dark)
            let indicator = JGProgressHUDErrorIndicatorView()
            hud.indicatorView = indicator
            hud.textLabel.text = "Connected"
            hud.show(in: view)
            hud.dismiss(afterDelay: 3.0)
        })
        
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.tag)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            yourLocalAddress = textField.text
            break
        case 1:
            yourUsername = textField.text
            break
        default:
            break
        }
        sshLabel.text = "ssh \(yourUsername ?? "yourUsername")@\(yourLocalAddress ?? "yourLocalAddress")"
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag {
        case 0:
            yourLocalAddress = textField.text
            break;
        case 1:
            yourUsername = textField.text
            break;
        default:
            break;
        }
        sshLabel.text = "ssh \(yourUsername ?? "yourUsername")@\(yourLocalAddress ?? "yourLocalAddress")"
        return true
    }
}
