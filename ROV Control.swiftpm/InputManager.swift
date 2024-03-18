//
//  InputManager.swift
//  ROV Control
//
//  Created by Kam Ho Leung on 29/1/2024.
//

import Foundation
import GameController
import SwiftUI

enum KeyShortcut : String, CaseIterable{
    case Forward = "w"
    case Backward = "s"
    case Left = "a"
    case Right = "d"
    case turn_Left = "q"
    case turn_Right = "e"
    case Up = "["
    case Down = "]"
}

class InputManager : ObservableObject{
    @Published var keyBoardState = [KeyShortcut : Bool]()
    @Published var outputState  = OutputState()
    @Published var connected = false
    @Published var controllerInput : GCControllerElement? = nil
    @Published var gamepad : GCExtendedGamepad? = nil
    init() {
        for input in KeyShortcut.allCases{
            self.keyBoardState[input] = false
        }
    }
    @objc func connectControllers() {
        //Used to register the Nimbus Controllers to a specific Player Number
        var indexNumber = 0
        self.connected = true
        // Run through each controller currently connected to the system
        for controller in GCController.controllers() {
            print(controller)
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if controller.extendedGamepad != nil {
                controller.playerIndex = GCControllerPlayerIndex.init(rawValue: indexNumber)!
                indexNumber += 1
                setupControllerControls(controller: controller)
            }
        }
    }
    @objc func disconnectControllers() {
        self.connected = false
    }
    func setupControllerControls(controller: GCController) {
        //Function that check the controller when anything is moved or pressed on it
        controller.extendedGamepad?.valueChangedHandler = {
            (gamepad: GCExtendedGamepad, element: GCControllerElement) in
            // Add movement in here for sprites of the controllers
            self.controllerInputDetected(gamepad: gamepad, element: element, index: controller.playerIndex.rawValue)
        }
    }
    func controllerInputDetected(gamepad: GCExtendedGamepad, element: GCControllerElement, index: Int) {
        self.gamepad = gamepad
        self.controllerInput = element
        switch(element){
        case gamepad.rightThumbstick:
//            self.outputState.turn_LR = CGFloat(gamepad.rightThumbstick.xAxis.value)
            self.outputState.UD = CGFloat(gamepad.rightThumbstick.yAxis.value)
        case gamepad.leftThumbstick:
            self.outputState.FB = CGFloat(gamepad.leftThumbstick.yAxis.value)
            self.outputState.LR = CGFloat(gamepad.leftThumbstick.xAxis.value)
        case gamepad.dpad.up:
            self.outputState.FB = 1
        case gamepad.dpad.down:
            self.outputState.FB = -1
        case gamepad.dpad.left:
            self.outputState.LR = -1
        case gamepad.dpad.right:
            self.outputState.LR = 1
        case gamepad.leftShoulder:
            self.outputState.turn_LR = (gamepad.leftShoulder.isPressed ? -1 : 0)
        case gamepad.rightShoulder:
            self.outputState.turn_LR = (gamepad.rightShoulder.isPressed ? 1 : 0)
        default:
            print(element)
        }
    }
    func ObserveForGameControllers() {
        NotificationCenter.default.addObserver(self, selector: #selector(connectControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    func updatekeyBoardState(key : String, state : Bool, outputPower : CGFloat){
        DispatchQueue.main.async{
            if let input = KeyShortcut(rawValue: key){
                self.keyBoardState[input]  = state
            }
            self.keyBoard2OutputState(new: self.keyBoardState)
        }
    }
    
    func keyBoard2OutputState(new : [KeyShortcut:Bool]){
        if let forward = new[.Forward],
           let backward = new[.Backward],
           let left = new[.Left],
           let right = new[.Right],
           let turn_Left = new[.turn_Left],
           let turn_right = new[.turn_Right],
           let up = new[.Up],
           let down = new[.Down]{
            if forward{
                self.outputState.FB = 1
            }else if backward{
                self.outputState.FB =  -1
            }else{
                self.outputState.FB = 0
            }
            if left{
                self.outputState.LR =  -1
            }else if right{
                self.outputState.LR = 1
            }else{
                self.outputState.LR = 0
            }
            if turn_Left{
                self.outputState.turn_LR = -1
            }else if turn_right{
                self.outputState.turn_LR = 1
            }else{
                self.outputState.turn_LR = 0
            }
            if up{
                self.outputState.UD = 1
            }else if down{
                self.outputState.UD = -1
            }else{
                self.outputState.UD = 0
            }
        }
    }
}
