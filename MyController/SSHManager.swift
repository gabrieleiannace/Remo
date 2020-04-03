//
//  SSHManager.swift
//  MyController
//
//  Created by Gabriele Iannace on 01/04/2020.
//  Copyright © 2020 Gabriele Iannace. All rights reserved.
//

import UIKit
import NMSSH

var tmp_image: UIImage!

class SSHManager{
    var session: NMSSHSession!
    var host: String!
    var username: String!
    var password: String!
    
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
    
    func terminalCommandExc(fullCommand: String){
        if(session.isAuthorized){
            session.channel.execute(fullCommand, error: nil)
        }
        else{
            //Something error
        }
    }
}
