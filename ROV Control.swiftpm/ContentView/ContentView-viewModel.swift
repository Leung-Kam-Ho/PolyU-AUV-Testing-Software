import SwiftUI
import GameController
import Vision


extension ContentView{
    
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

    @MainActor class ViewModel : ObservableObject {
        @Published var stream = true
        @Published var failCount = 0
        @Published var waterMark = UIImage(imageLiteralResourceName: "Watermark")
        @Published var waterMarkB = UIImage(imageLiteralResourceName: "Watermark").withRenderingMode(.alwaysTemplate).withTintColor(.black)
        @Published var footage : UIImage? = nil
        @Published var rovStatus = ROV_Status()
        @Published var log  = [String : Any]()
        @Published var FPS = 0

        var FPS_Count = 0
        // This Function is called when a controller is connected to the Apple TV
        
        
        
        func GET_Request(addr : Addr){
            if let url = URL(string: "http://\(addr.rawValue):5656"){
                var request = URLRequest(url: url,timeoutInterval: 5)
                request.httpMethod = "GET"
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        if let image_from_data = UIImage(data: data){
                            DispatchQueue.main.async {
                                self.footage = image_from_data
                                self.FPS_Count += 1
                            }
                        }else{
                            print("No Image")
                        }
                    }
                    if let response = response {
                        let httpResponse = response as! HTTPURLResponse
                        _ = httpResponse.allHeaderFields
                    }
                    if let error = error {
                        print("error sending message to \(url)  -> ",error.localizedDescription)
                    }
                }.resume()
            }
        }
        func POST_changeTask(addr : Addr, task : OnGoingTask){
            if let url = URL(string: "http://\(addr.rawValue):5656"){
                var request = URLRequest(url: url,timeoutInterval: 5)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let msgbody = ["command" : "task","task": task.rawValue] as [String : Any]
                let jsonbody = try? JSONSerialization.data(withJSONObject: msgbody)
                if let body = jsonbody {
                    request.httpBody = body
                }
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        do {
                            let status = try JSONDecoder().decode([String:String].self, from: data)
                            DispatchQueue.main.async {
                               print(status)
                            }
                        } catch {
                            print("Error decoding JSON:", error)
                        }
                    }
                    if let response = response {
                        let httpResponse = response as! HTTPURLResponse
                        _ = httpResponse.allHeaderFields
                    }
                    
                    if let error = error {
                        
                        print("error sending message to \(url) -> ",error.localizedDescription)
                    }
                    
                    
                }.resume()
            }
            
        }
        func POST_setMode(addr : Addr,mode:String){
            if let url = URL(string: "http://\(addr.rawValue):5656"){
                var request = URLRequest(url: url,timeoutInterval: 5)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let msgbody = ["command" : "mode","mode": mode] as [String : Any]
                let jsonbody = try? JSONSerialization.data(withJSONObject: msgbody)
                if let body = jsonbody {
                    request.httpBody = body
                }
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        do {
                            let status = try JSONDecoder().decode([String:String].self, from: data)
                            DispatchQueue.main.async {
                               print(status)
                            }
                        } catch {
                            print("Error decoding JSON:", error)
                        }
                    }
                    if let response = response {
                        let httpResponse = response as! HTTPURLResponse
                        _ = httpResponse.allHeaderFields
                    }
                    
                    if let error = error {
                        
                        print("error sending message to \(url) -> ",error.localizedDescription)
                    }
                    
                    
                }.resume()
            }
            
        }
        func POST_Request_Status(addr : Addr, update : OutputState? = nil, power : CGFloat = 0){
            if let url = URL(string: "http://\(addr.rawValue):5656"){
                var request = URLRequest(url: url,timeoutInterval: 5)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                var msgbody = ["command" : "status"] as [String : Any]
                if let update = update{
                    msgbody["log"] = ["FB" : update.FB * power,"LR" : update.LR * power,"turn_LR" : update.turn_LR * power,"UD" : update.UD * power]
                }
                let jsonbody = try? JSONSerialization.data(withJSONObject: msgbody)
                if let body = jsonbody {
                    request.httpBody = body
                }
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        do {
                            let status = try JSONDecoder().decode(ROV_Status.self, from: data)
                            DispatchQueue.main.async {
                                self.rovStatus = status
                            }
                        } catch {
                            print("Error decoding JSON:", error)
                        }
                    }
                    if let response = response {
                        let httpResponse = response as! HTTPURLResponse
                        _ = httpResponse.allHeaderFields
                    }
                    
                    if let error = error {
                        
                        print("error sending message to \(url) -> ",error.localizedDescription)
                    }
                    
                    
                }.resume()
            }
        }
        
    }
}
