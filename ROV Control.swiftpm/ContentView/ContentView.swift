import SwiftUI
import GameController


struct ContentView: View {
    @EnvironmentObject var settings : Settings
    @EnvironmentObject var inputManager : InputManager
    @Environment(\.colorScheme) private var colorScheme
    @State var viewModel = ViewModel()
    @State var tabViewSelection = "Main"
    @State var key : String = ""
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
        let infoView =
        Color.clear
            .overlay(alignment: .top, content:{
                HStack{
                    VStack{
                        let yaw_ref = Int(self.viewModel.rovStatus.yaw_ref)
                        Text("Yaw ref : \(yaw_ref)")
                    }.debugBackground()
                        .padding()
                    VStack{
                        Text("Dep_lev : \(self.viewModel.rovStatus.dep_lev)")
                    }.debugBackground()
                        .padding()
                }
            })
            .overlay(alignment: .bottomLeading, content: {
                VStack{
                    if self.viewModel.taskShow{
                        ScrollView(.vertical){
                            VStack(alignment: .listRowSeparatorLeading){
                                ForEach(OnGoingTask.allCases, id:\.self){ t in
                                    Button(action:{
                                        withAnimation{
                                            self.viewModel.POST_changeTask(addr: settings.getAddr(), task: t)
                                            self.viewModel.taskShow.toggle()
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
                            self.viewModel.taskShow.toggle()
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
                    if self.viewModel.modeShow{
                        ScrollView(.vertical){
                            VStack(alignment: .listRowSeparatorLeading){
                                
                                ForEach(viewModel.rovStatus.modeList, id:\.self){ mode in
                                    Button(action:{
                                        viewModel.POST_setMode(addr: settings.getAddr(), mode: mode)
                                        withAnimation{
                                            self.viewModel.modeShow.toggle()
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
                            self.viewModel.modeShow.toggle()
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
                    let paused = (settings.streamMode == .Pause)
                    Button(action:{
                        withAnimation{
                            if paused{
                                settings.streamMode = .Both
                            }else{
                                settings.streamMode = .Pause
                            }
                            
                        }
                    }){
                        Image(systemName: paused ? "pause.fill": "play.fill")
                    }
                    .debugBackground()
                    
                    Text(paused ? "Stream Paused" : "FPS: \(viewModel.fps_Counter.getFPS())")
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
                            let addr = self.settings.getAddr()
                            let output = !self.viewModel.clawOpen
                            self.viewModel.POST_Command_Claw(addr: addr, openArm: output)
                        }
                    }){
                        Label("Claw", systemImage: self.viewModel.clawOpen ?  "hands.clap" : "hands.clap.fill")
                            .labelStyle(.iconOnly)
                            .font(.title)
                            .debugBackground()
                        
                    }
                    Button(action:{
                        withAnimation{
                            self.viewModel.debugShow.toggle()
                        }
                    }){
                        Label("expend", systemImage: self.viewModel.debugShow ?  "chevron.right.circle.fill": "chevron.left.circle.fill")
                            .labelStyle(.iconOnly)
                            .font(.title)
                            .debugBackground()
                        
                    }
                    if self.viewModel.debugShow{
                        let FB = self.inputManager.outputState.FB
                        let LR = self.inputManager.outputState.LR
                        let turn = self.inputManager.outputState.turn_LR
                        let UD = self.inputManager.outputState.UD
                        let LRImg =  LR == 0 ? "arrow.left.arrow.right.circle.fill" : (LR > 0 ? "arrow.right.circle.fill" : "arrow.left.circle.fill")
                        let turnImg =  turn == 0 ? "repeat.circle.fill" : (turn > 0 ? "arrow.uturn.forward.circle.fill" : "arrow.uturn.backward.circle.fill")
                        let UDImg =  UD == 0 ? "minus.circle.fill" : (UD > 0 ? "arrowtriangle.up.circle.fill" : "arrowtriangle.down.circle.fill")
                        let FBImg =  FB == 0 ? "arrow.up.arrow.down.circle.fill" : (FB > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        Label {
                            Text(String(Int(viewModel.rovStatus.forwardPWM)))
                        } icon: {
                            Image(systemName: FBImg)
                                .font(.title)
                        }.debugBackground()
                        Label {
                            Text(String(Int(viewModel.rovStatus.LRPWM)))
                        } icon: {
                            Image(systemName: LRImg)
                                .font(.title)
                        }.debugBackground()
                        Label {
                            Text(String(Int(viewModel.rovStatus.yawPWM)))
                        } icon: {
                            Image(systemName: turnImg)
                                .font(.title)
                        }.debugBackground()
                        Label {
                            Text(String(Int(viewModel.rovStatus.depthPWM)))
                        } icon: {
                            Image(systemName: UDImg)
                                .font(.title)
                        }.debugBackground()
                        Label {
                            Text(String(Int(viewModel.rovStatus.rollPWM)))
                        } icon: {
                            Image(systemName: "sleep.circle.fill")
                                .font(.title)
                        }.debugBackground()
                    }
                    
                    let percentage = Int(settings.outputPower.rawValue)
                    Button(action: {
                        withAnimation{
                            viewModel.speedPopUp.toggle()
                        }
                    }){
                        
                        Text(String(percentage))
                            .font(.title)
                            .debugBackground()
                    }
                    .popover(isPresented: $viewModel.speedPopUp, content: {
                        HStack(content: {
                            Text("Power:")
                            Picker("Output Power (%)",selection: $settings.outputPower) {
                                ForEach(OutputPower.allCases, id:\.self){ outputPower in
                                    Text("\(Int(outputPower.rawValue))")
                                        .tag(outputPower)
                                    
                                }
                            }.pickerStyle(.segmented)
                        }).padding()
                    })
                    .buttonStyle(.plain)
                    
                    
                }
                .padding()
            })
        let mainView =
        CameraView(image: viewModel.footage ?? ( colorScheme == .dark ? viewModel.waterMark : viewModel.waterMarkB), mask : settings.generalObjectDetection ? self.viewModel.visionModel.result : nil)
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
                            Color.clear
                                .tag("clear")
                            infoView
                                .tag("Main")
                            VStack{
                                SettingsView()
                                    .tag("Settings")
                                Image("Anson")
                                    .resizable()
                                    .scaledToFit()
                            }
                        })
                        .tabViewStyle(.page)
                        
                    }
                    
                    
                    
                }else{
                    VStack{
                        TabView(selection:$tabViewSelection,content: {
                            mainView
                                .tag("Main")
                            SettingsView()
                                .tag("Settings")
                        }).clipShape(.rect(cornerRadius: 25))
                            .tabViewStyle(.page)
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
                    self.viewModel.POST_changeTask(addr: settings.getAddr(), task: .ROV)
                    print("ROV")
                }
                else if new == gamepad.buttonB{
                    self.viewModel.POST_changeTask(addr: settings.getAddr(), task: .TASK_Demo)
                    print("Demo")
                }
                else if new == gamepad.buttonX{
                    self.viewModel.POST_changeTask(addr: settings.getAddr(), task: .TASK_Qulification)
                    print("Quli")
                }else if new == gamepad.leftTrigger{
                    self.viewModel.POST_Command_Claw(addr: settings.getAddr(), openArm: true)
                    print("Open")
                }
                else if new == gamepad.rightTrigger{
                    self.viewModel.POST_Command_Claw(addr: settings.getAddr(), openArm: false)
                    print("Close")
                }
            }
            
        })
        .onChange(of: settings.modelURL, { old, new in
            if let modelURL = new{
                settings.modelState = .uploading
                DispatchQueue.global(qos: .userInitiated).async {
                    let success = self.viewModel.visionModel.setupObjectDetectionModel(modelURL)
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
            self.StartCameraLoop()
            self.StartCommandLoop()
        })
        
    }
    func StartCommandLoop(){
        DispatchQueue.global(qos: .userInitiated).async{
            while true{
                if settings.streamMode == .Both || settings.streamMode == .InputOnly{
                    viewModel.POST_Request_Status(addr: settings.getAddr(), update: self.inputManager.outputState,power:settings.outputPower.rawValue)
                }
            }
        }
    }
    func StartCameraLoop(){
        DispatchQueue.global(qos: .userInitiated).async{
            while true{
                if settings.streamMode == .Both || settings.streamMode == .VideoOnly{
                    viewModel.GET_Request(addr:settings.getAddr())
                    if settings.generalObjectDetection{
                        if let footage = viewModel.footage{
                            self.viewModel.visionModel.processImage_YOLOv3(footage)
                        }
                    }
                }
                
            }
        }
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


extension View {
    func debugBackground() -> some View {
        modifier(DBG())
    }
}


