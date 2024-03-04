//
//  DebugView.swift
//  ROV Control
//
//  Created by Kam Ho Leung on 1/2/2024.
//

import SwiftUI

struct ROV_Status : Decodable{
    let pitch : Float
    let roll : Float
    let yaw : Float
    let yaw_ref : Float
    let dep_lev : Float
    let roll_ref : Float
    let dep_lev_ref : Float
    let forwardPWM : Float
    let LRPWM : Float
    let depthPWM : Float
    let rollPWM : Float
    let yawPWM : Float
    let modeList : [String]
    let mode : String
    let task : String
    init(pitch: Float = 0, roll: Float  = 0, yaw: Float  = 0, yaw_ref: Float = 0, dep_lev: Float = 0, roll_ref: Float = 0, dep_lev_ref: Float = 0, forwardPWM: Float = 0, LRPWM: Float = 0, depthPWM: Float = 0, rollPWM: Float = 0, yawPWM : Float = 0, modeList : [String] = [String](),mode : String = "Not Connected", task : String = "") {
        self.pitch = pitch
        self.roll = roll
        self.yaw = yaw
        self.yaw_ref = yaw_ref
        self.dep_lev = dep_lev
        self.roll_ref = roll_ref
        self.dep_lev_ref = dep_lev_ref
        self.forwardPWM = forwardPWM
        self.LRPWM = LRPWM
        self.depthPWM = depthPWM
        self.rollPWM = rollPWM
        self.yawPWM = yawPWM
        self.modeList = modeList
        self.mode = mode
        self.task = task
    }
    
}


enum ROVCommand : String{
    case FB // Forward or Backward
    case LR // Left or Right
    case turn_LR // turn left or ight
    case UD // Up or down
}




