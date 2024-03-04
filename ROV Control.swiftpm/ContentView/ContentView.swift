import SwiftUI
import GameController


struct ContentView: View {
    @EnvironmentObject var settings : Settings
    @EnvironmentObject var inputManager : InputManager
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var viewModel = ViewModel()
    @StateObject var visionViewModel = VisionViewModel()
    @State var tabViewSelection = "Camera"
    @State var key : String = ""
    @State var modeShow = false
    @State var taskShow = false
    @State var debugShow = false
    let blockMaxHeight : CGFloat = 150
    let blockMaxWidth : CGFloat = 150
    
    var body: some View {
        
        let forwardSignal =
        ControlButton(selectedColor: self.inputManager.outputState.FB > 0 ? .accentColor : .primary,icon: "arrowshape.up.circle.fill", press_action : {
            self.inputManager.outputState.FB = settings.outputPower.rawValue
        },release_action:{
            self.inputManager.outputState.FB = 0
        })
        .frame(maxWidth: blockMaxWidth,maxHeight:blockMaxHeight)
        let backwardSignal =
        ControlButton(selectedColor: self.inputManager.outputState.FB < 0 ? .accentColor : .primary,icon: "arrowshape.down.circle.fill", press_action : {
            self.inputManager.outputState.FB = -settings.outputPower.rawValue
        },release_action:{
            self.inputManager.outputState.FB = 0
        })
        .frame(maxWidth: blockMaxWidth,maxHeight:blockMaxHeight)
        let turnLeftSignal =
        ControlButton(selectedColor: self.inputManager.outputState.turn_LR < 0 ? .accentColor : .primary,icon: "arrow.uturn.backward.circle.fill", press_action : {
            self.inputManager.outputState.turn_LR = -5
        },release_action:{
            self.inputManager.outputState.turn_LR = 0
        })
        .frame(maxWidth: blockMaxWidth,maxHeight:blockMaxHeight)
        let turnRightSignal =
        ControlButton(selectedColor: self.inputManager.outputState.turn_LR > 0 ? .accentColor : .primary,icon: "arrow.uturn.right.circle.fill", press_action : {
            self.inputManager.outputState.turn_LR = 5
        },release_action:{
            self.inputManager.outputState.turn_LR = 0
        })
        .frame(maxWidth: blockMaxWidth,maxHeight:blockMaxHeight)
        let leftSignal =
        ControlButton(selectedColor: self.inputManager.outputState.LR < 0 ? .accentColor : .primary,icon: "arrowshape.left.circle.fill", press_action : {
            self.inputManager.outputState.LR = -settings.outputPower.rawValue
        },release_action:{
            self.inputManager.outputState.LR = 0
        })
        .frame(maxWidth: blockMaxWidth,maxHeight:blockMaxHeight)
        let rightSignal =
        ControlButton(selectedColor: self.inputManager.outputState.LR > 0 ? .accentColor : .primary,icon: "arrowshape.right.circle.fill", press_action : {
            self.inputManager.outputState.LR = settings.outputPower.rawValue
        },release_action:{
            self.inputManager.outputState.LR = 0
        })
        .frame(maxWidth: blockMaxWidth,maxHeight:blockMaxHeight)
        let upSignal =
        ControlButton(selectedColor: self.inputManager.outputState.UD < 0 ? .accentColor : .primary,icon: "water.waves.and.arrow.up", press_action : {
            self.inputManager.outputState.UD = settings.outputPower.rawValue
        },release_action:{
            self.inputManager.outputState.UD = 0
        })
        .frame(maxWidth: blockMaxWidth,maxHeight:blockMaxHeight)
        //water.waves.and.arrow.down
        let downSignal =
        ControlButton(selectedColor: self.inputManager.outputState.UD < 0 ? .accentColor : .primary,icon: "water.waves.and.arrow.down", press_action : {
            self.inputManager.outputState.UD = -settings.outputPower.rawValue
        },release_action:{
            self.inputManager.outputState.UD = 0
        })
        .frame(maxWidth: blockMaxWidth,maxHeight:blockMaxHeight)
        
        let slidingPadLeft =
        SlidingPad(horizontalValue: self.$inputManager.outputState.LR,
                   verticalValue: self.$inputManager.outputState.FB,
                   horizontalMax: CGFloat(self.settings.outputPower.rawValue),
                   verticalMax: CGFloat(self.settings.outputPower.rawValue))
        
        let slidingPadRight =
        SlidingPad(horizontalValue: self.$inputManager.outputState.turn_LR,
                   verticalValue: self.$inputManager.outputState.UD,
                   horizontalMax:  CGFloat(self.settings.outputPower.rawValue),
                   verticalMax:  CGFloat(self.settings.outputPower.rawValue))
        let infoView =
        Color.clear
            .overlay(alignment: .top, content:{
                let pitch = Double(viewModel.rovStatus.pitch)
                let roll = Double(viewModel.rovStatus.roll)
                let yaw = Double(viewModel.rovStatus.yaw)
                VStack{
                    Image(systemName: "airplane.circle.fill")
                        .font(.title)
                        .rotationEffect(Angle(degrees: -90))
                        .rotation3DEffect(Angle(degrees: pitch), axis: (-1,0,0))
                        .rotation3DEffect(Angle(degrees: roll), axis: (0,1,0))
                        .rotation3DEffect(Angle(degrees: yaw), axis: (0,0,1))
                }.debugBackground()
                    .padding()
            })
            .overlay(alignment: .bottomLeading, content: {
                VStack{
                    if self.taskShow{
                        ScrollView(.vertical){
                            VStack(alignment: .listRowSeparatorLeading){
                                
                                ForEach(OnGoingTask.allCases, id:\.self){ t in
                                    Button(action:{
                                        withAnimation{
                                            self.viewModel.POST_changeTask(addr: settings.addr, task: t)
                                            self.taskShow.toggle()
                                        }
                                    }){
                                        Label(t.rawValue, systemImage: t == .ROV ? "r.circle.fill" : "a.circle.fill")
                                    }.padding()
                                }
                            }
                        }.scrollContentBackground(.hidden)
                            .frame(maxHeight:500)
                    }
                    Button(action:{
                        withAnimation{
                            self.taskShow.toggle()
                        }
                    }){
                        let t = viewModel.rovStatus.task
                        Label{
                            Text(t.isEmpty ? "Not Connected" : t)
                        } icon:{
                            Image(systemName:"chevron.up.circle.fill")
                                .font(.title)
                        }
                    }
                }
                .debugBackground()
                .padding()
            })
            .overlay(alignment:.bottomTrailing,content:{
                VStack{
                    if self.modeShow{
                        ScrollView(.vertical){
                            VStack(alignment: .listRowSeparatorLeading){
                                
                                ForEach(viewModel.rovStatus.modeList, id:\.self){ mode in
                                    Button(action:{
                                        viewModel.POST_setMode(addr: settings.addr, mode: mode)
                                        withAnimation{
                                            
                                            self.modeShow.toggle()
                                        }
                                    }){
                                        Label(mode, systemImage: "\(mode.lowercased().first ?? "1").circle.fill")
                                    }.padding()
                                }
                            }
                        }.scrollContentBackground(.hidden)
                            .frame(maxHeight:500)
                    }
                    Button(action:{
                        withAnimation{
                            self.modeShow.toggle()
                        }
                    }){
                        Label{
                            Text((viewModel.rovStatus.mode))
                        } icon:{
                            Image(systemName:"chevron.up.circle.fill")
                                .font(.title)
                        }
                    }
                }
                .debugBackground()
                .padding()
            })
            .overlay(alignment: .topLeading, content: {
                HStack{
                    Text("FPS: \(viewModel.FPS)")
                        .debugBackground()
                }.padding()

                
            })
            .overlay(alignment: .topTrailing, content: {
                HStack{
                    Image(systemName: self.inputManager.connected ? "gamecontroller.fill" : "keyboard.fill" )
                        .debugBackground()
                }.padding()
            })
            .overlay(alignment: .bottom, content: {
                HStack{
                    Button(action:{
                        withAnimation{
                            self.debugShow.toggle()
                        }
                    }){
                        Label("expend", systemImage: self.debugShow ?  "chevron.right.circle.fill": "chevron.left.circle.fill")
                            .labelStyle(.iconOnly)
                            .font(.title)
                            .debugBackground()
                        
                    }
                    if self.debugShow{
                        let FB = self.inputManager.outputState.FB
                        let LR = self.inputManager.outputState.LR
                        let turn = self.inputManager.outputState.turn_LR
                        let UD = self.inputManager.outputState.UD
                        let LRImg =  LR == 0 ? "arrow.left.arrow.right.circle.fill" : (LR > 0 ? "arrow.right.circle.fill" : "arrow.left.circle.fill")
                        let turnImg =  turn == 0 ? "repeat.circle.fill" : (turn > 0 ? "arrow.uturn.forward.circle.fill" : "arrow.uturn.backward.circle.fill")
                        let UDImg =  UD == 0 ? "minus.circle.fill" : (UD > 0 ? "arrowtriangle.up.circle.fill" : "arrowtriangle.down.circle.fill")
                        let FBImg =  FB == 0 ? "arrow.up.arrow.down.circle.fill" : (FB > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        Label {
                            Text(String(format: "%.2f",viewModel.rovStatus.forwardPWM))
                        } icon: {
                            Image(systemName: FBImg)
                                .font(.title)
                        }.debugBackground()
                        Label {
                            Text(String(format: "%.2f",viewModel.rovStatus.LRPWM))
                        } icon: {
                            Image(systemName: LRImg)
                                .font(.title)
                        }.debugBackground()
                        Label {
                            Text(String(format: "%.2f",viewModel.rovStatus.yawPWM))
                        } icon: {
                            Image(systemName: turnImg)
                                .font(.title)
                        }.debugBackground()
                        Label {
                            Text(String(format: "%.2f",viewModel.rovStatus.depthPWM))
                        } icon: {
                            Image(systemName: UDImg)
                                .font(.title)
                        }.debugBackground()
                        Label {
                            Text(String(format: "%.2f",viewModel.rovStatus.rollPWM))
                        } icon: {
                            Image(systemName: "sleep.circle.fill")
                                .font(.title)
                        }.debugBackground()
                    }
                    
                    let percentage = Int(settings.outputPower.rawValue)
                    Button(action: {
                        withAnimation{
                            settings.outputPower = settings.outputPower.next()
                        }
                    }){
                        Label {
                            Text(String(percentage))
                        } icon: {
                            Image(systemName: "gauge.with.dots.needle.\(percentage)percent")
                                .font(.title)
                        }.debugBackground()
                    }
                    .buttonStyle(.plain)

                    
                }
                .padding()
            })
        let mainView =
        CameraView(image: viewModel.footage ?? ( colorScheme == .dark ? viewModel.waterMark : viewModel.waterMarkB), mask : settings.generalObjectDetection ? visionViewModel.result : nil)
            .tag("Camera")
            .focusable()
            .onKeyPress(phases: .all, action: { press in
                //                    if !self.inputManager.connected{
                let key = press.characters
                self.key = key
                if press.phase == .down{
                    self.inputManager.updatekeyBoardState(key: key, state: true, outputPower : self.settings.outputPower.rawValue)
                }else if press.phase == .up{
                    self.key = ""
                    self.inputManager.updatekeyBoardState(key: key, state: false, outputPower:  self.settings.outputPower.rawValue)
                }
                
                return .handled
                //                    }
                //                    return .ignored
                
            })
        
        
        /*MainView Starts here*/
        GeometryReader { g in
            let height = g.size.height
            let width = g.size.width
            let verticalView = (height >= width)
            
            VStack{
                if !verticalView{
                        ZStack{
                            mainView
                            //                                    .frame(width: width,height:height)
                            TabView(selection:$tabViewSelection,content: {
                               
                                infoView
                                    .tag("main")
                                VStack{
                                    SettingsView()
                                        .tag("Settings")
                                    Image("Anson")
                                        .resizable()
                                        .scaledToFit()
                                }
                            })
                            .tabViewStyle(.page)
                            if tabViewSelection == "Camera"{
                                if settings.virtualJoyStick{
                                    Color.clear
                                        .overlay(alignment: .bottomLeading, content: {
                                            slidingPadLeft
                                        })
                                        .overlay(alignment: .bottomTrailing, content: {
                                            slidingPadRight
                                        })
                                }
                            }
                            
                        }
                        
                    
                    
                }else{
                    VStack{
                        mainView
                            .clipShape(.rect(cornerRadius: 25))
                            .frame(height: CGFloat(height*0.4))
                        
                        VStack{
                            HStack{
                                VStack{
                                    turnLeftSignal
                                    forwardSignal
                                    backwardSignal
                                    leftSignal
                                    
                                }
                                VStack{
                                    turnRightSignal
                                    upSignal
                                    downSignal
                                    rightSignal
                                }
                                
                            }
                        }
                        .padding(.vertical)
                    }.padding()
                        .frame(width: width, height: height) //somehow everything aligned to top left corner
                }
            }
            
        }
        .onChange(of: inputManager.controllerInput, { old, new in
            if let new = new,
               let gamepad = inputManager.gamepad{
                if new == gamepad.buttonA{
                    self.viewModel.POST_changeTask(addr: settings.addr, task: .ROV)
                    print("ROV")
                }
                else if new == gamepad.buttonB{
                    self.viewModel.POST_changeTask(addr: settings.addr, task: .TASK_Demo)
                    print("Demo")
                }
            }
            
        })
        .onChange(of: settings.modelURL, { old, new in
            if let modelURL = new{
                settings.modelState = .uploading
                DispatchQueue.global(qos: .userInitiated).async {
                    let success = visionViewModel.setupObjectDetectionModel(modelURL)
                    if success{
                        settings.modelState = .uploaded
                    }else{
                        settings.modelState = .fail
                    }
                }
                
            }
        })
        .onAppear(perform: {
            self.inputManager.ObserveForGameControllers()
            Timer.scheduledTimer(withTimeInterval: 1/15, repeats: true) { timer in
                if settings.streamMode == .Both || settings.streamMode == .VideoOnly{
                    viewModel.GET_Request(addr:settings.addr)
                    if settings.generalObjectDetection{
                        if let footage = viewModel.footage{
                            visionViewModel.processImage_YOLOv3(footage)
                        }
                    }
                }
                
                
            }
            Timer.scheduledTimer(withTimeInterval: 1/10, repeats: true){ timer in
                if settings.streamMode == .Both || settings.streamMode == .InputOnly{
                    viewModel.POST_Request_Status(addr: settings.addr, update: self.inputManager.outputState,power:settings.outputPower.rawValue)
                }
                
            }
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
                viewModel.FPS = viewModel.FPS_Count
                viewModel.FPS_Count = 0
            }
            
        })
        
    }
    
}

struct DBG: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.orange)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 25))
            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
    }
}
struct DBG_noPad: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.orange)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 25))
            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
    }
}

extension View {
    func debugBackground() -> some View {
        modifier(DBG())
    }
    func debugBackground_noPad() -> some View {
        modifier(DBG_noPad())
    }
}


