import SwiftUI


enum Addr : String, CaseIterable{
    case rov = "rov.local"
    case auv = "auv.local"
    case home = "Kam-Air.local"
    case Lab = "Kam-Studio.local"
    case custom = "custom Address"
}

enum OnGoingTask : String, CaseIterable{
    case TASK_Demo
    case TASK_Qulification
    case TASK_Navigation
    case TASK_Acquisition
    case Task_Reacquisition
    case Task_Localization
    case Surface
    case ROV
}

enum BackgroundMode : String, CaseIterable{
    case dotBreathing
    case breathing
    case Icon
    case none
}

enum ModelState : String{
    case noModel
    case uploading
    case uploaded
    case fail
}

enum OutputPower : CGFloat, CaseIterable{
    case LogicTest = 20
    case LabTest = 30
    case PoolTest = 50
    case SAUVC_A = 60
    case SAUVC_B = 70
    case SAUVC_C = 80
    case Full = 90
}

enum StreamMode : String, CaseIterable{
    case Both
    case VideoOnly
    case InputOnly
    case Pause
}

extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}

class Settings : ObservableObject{
    @Published var addr : Addr = .rov
    @Published var customAddr : String = "localhost"
    @Published var backgroundMode : BackgroundMode = .Icon
    @Published var generalObjectDetection = true
    @Published var modelState : ModelState = .noModel
    @Published var modelURL : URL? = nil
    @Published var outputPower : OutputPower = .SAUVC_C
    @Published var streamMode : StreamMode = .Pause
    func getAddr() -> String{
        if self.addr == .custom{
            return self.customAddr
        }
        return self.addr.rawValue
    }
}
