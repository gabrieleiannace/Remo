//
//  ViewController.swift
//  MyController
//
//  Created by Gabriele Iannace on 23/03/2020.
//  Copyright © 2020 Gabriele Iannace. All rights reserved.
//

import UIKit
import NMSSH

class ViewController: UIViewController {
    var session: NMSSHSession!
    var mutex = DispatchSemaphore(value: 1)
    @IBOutlet weak var sessionLED: UIImageView!
    @IBOutlet weak var address_Label: UILabel!
    
    //*******VARIABILI DI PASSAGGIO***
    
    var input_host: String!
    var input_username: String!
    var input_password: String!
    
    //**********ARROW SECTION*********
    
    @IBOutlet weak var downArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var upArrow: UIButton!
    @IBOutlet weak var downVolume: UIButton!
    @IBOutlet weak var upVolume: UIButton!
    @IBOutlet weak var muteVolume: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var enterButton: UIButton!
    
    //****************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        address_Label.text! += " \(input_host!)"
        overrideUserInterfaceStyle = .dark
        longPressActivation()
    }
    
    func longPressActivation(){
        //Up volume
        let upVol_longpress = UILongPressGestureRecognizer(target: self, action: #selector(upVolL(sender: )))
        upVol_longpress.minimumPressDuration = TimeInterval(exactly: 0.2)!
        upVolume.addGestureRecognizer(upVol_longpress)
        //Down volume
        
        let downVol_longpress = UILongPressGestureRecognizer(target: self, action: #selector(downVolL(sender: )))
        downVol_longpress.minimumPressDuration = TimeInterval(exactly: 0.2)!
        downVolume.addGestureRecognizer(downVol_longpress)
        
        //Up Arrow
        let upArrow_longpress = UILongPressGestureRecognizer(target: self, action: #selector(upArrL(sender: )))
        upArrow_longpress.minimumPressDuration = TimeInterval(exactly: 0.2)!
        upArrow.addGestureRecognizer(upArrow_longpress)
        
        //Down Arrow
        let downArrow_longpress = UILongPressGestureRecognizer(target: self, action: #selector(downArrL(sender: )))
        downArrow_longpress.minimumPressDuration = TimeInterval(exactly: 0.2)!
        downArrow.addGestureRecognizer(downArrow_longpress)
        
        //Left Arrow
        let leftArrow_longpress = UILongPressGestureRecognizer(target: self, action: #selector(leftArrL(sender: )))
        leftArrow_longpress.minimumPressDuration = TimeInterval(exactly: 0.2)!
        leftArrow.addGestureRecognizer(leftArrow_longpress)
        
        //Right Arrow
        let rightArrow_longpress = UILongPressGestureRecognizer(target: self, action: #selector(rightArrL(sender: )))
        rightArrow_longpress.minimumPressDuration = TimeInterval(exactly: 0.2)!
        rightArrow.addGestureRecognizer(rightArrow_longpress)
        
    }
    
    func checkForTechnologies(){
        terminalCommandExc(fullCommand: "echo \(input_password!) | sudo -S apt-get install xdotool")
        sleep(1)
        let response = session.channel.lastResponse
        print(response)
        if (response?.contains("is already the newest version"))!{
            print("sei un tipo ok")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForTechnologies()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        SSHDisconnect();
    }
    
    func SSHConnect(hostname: String, username: String, password: String){
        session = NMSSHSession(host: hostname, andUsername: username)
        session.connect()
        if session.isConnected == true{
            session.authenticate(byPassword: password)
            if(session.isAuthorized){
                print("Session Authorized!");
            }
        }
    }
    
    func SSHDisconnect(){
        if session.isAuthorized{
            session.disconnect()
            print("Session Disconnected!")
        }
        else{
            print("You can't disconnct a non-authorized connection")
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        session.disconnect()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func inputAction(_ sender: UIButton) {
        var currentCommand: String!
        switch sender.tag {
        case upArrow.tag:
            currentCommand = " Up";
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool key\(currentCommand!) gabbo");
            break;
        
        case downArrow.tag:
            currentCommand = " Down";
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool key\(currentCommand!) gabbo");
            break;
            
        case leftArrow.tag:
            currentCommand = " Left";
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool key\(currentCommand!) gabbo");
            break;
            
        case rightArrow.tag:
            currentCommand = " Right";
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool key\(currentCommand!) gabbo");
            break;
        case enterButton.tag:
            currentCommand = " Return";
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool key\(currentCommand!) gabbo");
            break;
        case upVolume.tag:
            currentCommand = " F10";
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool key\(currentCommand!) gabbo");
            break
        case downVolume.tag:
            currentCommand = " F9";
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool key \(currentCommand!) gabbo");
            break
        case muteVolume.tag:
            currentCommand = " F8";
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool key \(currentCommand!)")
            
        case backButton.tag:
            currentCommand = " Escape";
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool key \(currentCommand!)")
        default:
            //Nothing to do
            break;
        }
    }
    
    func terminalCommandExc(fullCommand: String){
        DispatchQueue.global().async(qos: .userInteractive) {
            print(self.session.channel.execute(fullCommand, error: nil, timeout: 1) ?? "")
        }
    }

}

extension ViewController{
    @objc func upVolL(sender: UILongPressGestureRecognizer){
        switch sender.state {
        case .began:
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool keydown F10")
            break
        case .ended:
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool keyup F10")
            break
        default:
            //Nothing
            break
        }
    }
    @objc func downVolL(sender: UILongPressGestureRecognizer){
        switch sender.state {
        case .began:
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool keydown F9")
            break
        case .ended:
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool keyup F9")
            break
        default:
            //Nothing
            break
        }
    }
    @objc func upArrL(sender: UILongPressGestureRecognizer){
        switch sender.state {
        case .began:
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool keydown Up")
            break
        case .ended:
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool keyup Up")
            break
        default:
            //Nothing
            break
        }
    }
    @objc func downArrL(sender: UILongPressGestureRecognizer){
        switch sender.state {
        case .began:
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool keydown Down")
            break
        case .ended:
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool keyup Down")
            break
        default:
            //Nothing
            break
        }
    }
    @objc func leftArrL(sender: UILongPressGestureRecognizer){
        switch sender.state {
        case .began:
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool keydown Left")
            break
        case .ended:
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool keyup Left")
            break
        default:
            //Nothing
            break
        }
    }
    @objc func rightArrL(sender: UILongPressGestureRecognizer){
        switch sender.state {
        case .began:
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool keydown Right")
            break
        case .ended:
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool keyup Right")
            break
        default:
            //Nothing
            break
        }
    }
}

extension NMSSHChannel{
    func execute(command: NSString, error: NSError, timeout: NSNumber){
        
        print("heyciao")
    }
}
