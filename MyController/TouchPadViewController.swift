//
//  TouchPadViewController.swift
//  MyController
//
//  Created by Gabriele Iannace on 24/03/2020.
//  Copyright © 2020 Gabriele Iannace. All rights reserved.
//

import UIKit
import NMSSH

class TouchPadViewController: UIViewController {
    var session: NMSSHSession!
    var input_host: String!
    var input_username: String!
    var input_password: String!
    
    var currentLocation: CGPoint!
    var mouseX_location: Int!
    var mouseY_locatoin: Int!
    var tmpSwap: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SSHConnect(hostname: input_host, username: input_username, password: input_password);
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(mouseMove))
        pan.maximumNumberOfTouches = 1;
        pan.minimumNumberOfTouches = 1;
        view.addGestureRecognizer(pan)
        
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
    
    @objc func mouseMove(_ sender: UIPanGestureRecognizer){
        if sender.state == .began{
            getMouseLocation()
            print("Start : \(sender.location(in: view))")
            currentLocation = sender.location(in: view)
        }
        else{
            usleep(1000)
            let myX = (self.currentLocation.x - sender.location(in: self.view).x)
            let myY = (self.currentLocation.y - sender.location(in: self.view).y)
//            print("X: \(self.currentLocation.x - sender.location(in: self.view).x)")
//            print("Y: \(self.currentLocation.y - sender.location(in: self.view).y)")
            self.currentLocation = sender.location(in: self.view)
            mouseX_location += Int(myX)
            mouseY_locatoin += Int(myY)
            terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool mousemove \(mouseX_location!) \(mouseY_locatoin!)")
            print(session.channel.lastResponse!)
        }
    }
    
    func getMouseLocation(){
        terminalCommandExc(fullCommand: "DISPLAY=:'0.0' xdotool getmouselocation")
        tmpSwap = session.channel.lastResponse
        let idx_y = tmpSwap.firstIndex(of: "y")
        let idx_screen = tmpSwap.firstIndex(of: "s")
        let startIndex = tmpSwap.index(tmpSwap.startIndex, offsetBy: 2)
        let valX = tmpSwap[(tmpSwap.index(startIndex, offsetBy: 0))..<(tmpSwap.index(before: idx_y!))]
        let valY = tmpSwap[tmpSwap.index(idx_y!, offsetBy: 2)..<(tmpSwap.index(before: idx_screen!))]
        mouseX_location = Int(valX)!
        mouseY_locatoin = Int(valY)!
    }
        
    func terminalCommandExc(fullCommand: String){
        if(session.isAuthorized){
            session.channel.execute(fullCommand, error: nil)
        }
        else{
            //Something error
        }
    }
}



