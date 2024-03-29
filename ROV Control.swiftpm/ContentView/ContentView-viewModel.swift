import SwiftUI
import GameController
import Vision


extension ContentView{
    
    class FPS_Counter{
        var FPS = 0
        var FPS_Count = 0
        init(){
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
                self.log()
            }
        }
        func getFPS() -> Int{
            return self.FPS
        }
        func log(){
            self.FPS = self.FPS_Count
            self.FPS_Count = 0
        }
        func step(){
            self.FPS_Count += 1
        }
    }
    
    @Observable
    class ViewModel {
        var stream = true
        var modeShow = false
        var taskShow = false
        var speedPopUp = false
        var debugShow = false
        var clawOpen = false
        let waterMark = UIImage(imageLiteralResourceName: "Watermark")
        let waterMarkB = UIImage(imageLiteralResourceName: "Watermark").withRenderingMode(.alwaysTemplate).withTintColor(.black)
        let visionModel = VisionViewModel()
        var footage : UIImage? = nil
        var rovStatus = ROV_Status()
        var log  = [String : Any]()
        let fps_Counter = FPS_Counter()
        let camera_semaphore = DispatchSemaphore(value: 1)
        let status_semaphore = DispatchSemaphore(value: 1)
        
        func GET_Request(addr : String){
            if let url = URL(string: "http://\(addr):5656"){
                var request = URLRequest(url: url, timeoutInterval: TimeInterval(0.5))
                request.httpMethod = "GET"
                self.camera_semaphore.wait()
                URLSession.shared.dataTask(with: request) { data, response, error in
                    defer { self.camera_semaphore.signal() }
                    if let data = data {
                        if let image_from_data = UIImage(data: data){
                            DispatchQueue.main.async {
                                self.footage = image_from_data
                                self.fps_Counter.step()
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
        func POST_changeTask(addr : String, task : OnGoingTask){
            if let url = URL(string: "http://\(addr):5656"){
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
        func POST_setMode(addr : String,mode:String){
            if let url = URL(string: "http://\(addr):5656"){
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
        
        func POST_Command_Claw(addr : String, openArm : Bool){
            if let url = URL(string: "http://\(addr):5656"){
                var request = URLRequest(url: url,timeoutInterval: 5)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let msgbody = ["command" : "servo","open" : openArm] as [String : Any]
                let jsonbody = try? JSONSerialization.data(withJSONObject: msgbody)
                if let body = jsonbody {
                    request.httpBody = body
                }
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        do {
                            let status = try JSONDecoder().decode([String:Bool].self, from: data)
                            DispatchQueue.main.async {
                                if let openClose = status["open"]{
                                    self.clawOpen = openClose
                                }
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
        func POST_Request_Status(addr : String, update : OutputState? = nil, power : CGFloat = 0){
            if let url = URL(string: "http://\(addr):5656"){
                var request = URLRequest(url: url,timeoutInterval: 1)
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
                self.status_semaphore.wait()
                print("go")
                URLSession.shared.dataTask(with: request) { data, response, error in
                    defer { self.status_semaphore.signal() }
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
