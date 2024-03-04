import SwiftUI


enum Addr : String, CaseIterable{
    case rov = "rov.local"
    case auv = "auv.local"
    case home = "Kam-Air.local"
    case Lab = "Kam-Studio.local"
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
    case Per_10 = 10
    case Quarter = 33
    case Half = 50
    case Full = 100
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
    @Published var backgroundMode : BackgroundMode = .Icon
    @Published var generalObjectDetection = true
    @Published var modelState : ModelState = .noModel
    @Published var modelURL : URL? = nil
    @Published var outputPower : OutputPower = .Quarter
    @Published var virtualJoyStick = false
    @Published var compactDebugView = true
    @Published var streamMode : StreamMode = .Both
}
