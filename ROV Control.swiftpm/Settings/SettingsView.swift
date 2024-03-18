import SwiftUI
import CoreML
import UniformTypeIdentifiers
struct SettingsView : View{
    @EnvironmentObject var settings : Settings
    @State var fileUpload = false
    var body: some View{
        Section{
            Form{
                //Picker to change to target ip
                //Switch between testing device e.g., lab mac studio and ROV
                HStack{
                    Text("Address:")
                    Picker("Address",selection: $settings.addr) {
                        ForEach(Addr.allCases, id:\.self){ addr in
                            Text(addr.rawValue).tag(addr)
                            
                        }
                    }.pickerStyle(.segmented)
                    
                }
                if settings.addr == .custom{
                    HStack{
                        Text("Custom Address:")
                        Color.clear
                        TextField("e.g., auv.loca", text: $settings.customAddr)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                HStack{
                    Text("Stream Mode:")
                    Picker("Stream Mode",selection: $settings.streamMode) {
                        ForEach(StreamMode.allCases, id:\.self){ streamMode in
                            Text(streamMode.rawValue)
                                .tag(streamMode)
                            
                        }
                    }.pickerStyle(.segmented)
                    
                }
                
                HStack{
                    Text("Background Mode:")
                    Picker("Background Mode",selection: $settings.backgroundMode) {
                        ForEach(BackgroundMode.allCases, id:\.self){ background in
                            Text(background.rawValue)
                                .tag(background)
                            
                        }
                    }.pickerStyle(.segmented)
                    
                }
                HStack{
                    Text("Power Mode")
                    Spacer()
                    Picker("Output Power (%)",selection: $settings.outputPower) {
                        ForEach(OutputPower.allCases, id:\.self){ outputPower in
                            Text("\(outputPower.rawValue)")
                                .tag(outputPower)
                            
                        }
                    }.pickerStyle(.segmented)
                }
                HStack{
                    Text("Object Detection Model")
                    Spacer()
                    if settings.modelState == .uploading{
                        ProgressView()
                    }else{
                        Button(settings.modelState.rawValue){
                            fileUpload = true
                        }
                    }
                    
                }
                Toggle(isOn: $settings.generalObjectDetection) {
                    // further development
                    Text("General Object Detection")
                }
                
            }.scrollContentBackground(.hidden)
                .fileImporter(isPresented: $fileUpload, allowedContentTypes: [.mlmodel,.mlpackage], onCompletion: { result in
                    switch result{
                    case .success(let url):
                        if url.startAccessingSecurityScopedResource(){
                            settings.modelURL = url
                        }
                    case .failure(let error):
                        print("loading model \(error)")
                    }
                })
        }
        
    }
}
private extension UTType {
    static let mlpackage = UTType(filenameExtension: "mlpackage", conformingTo: .item)!
    static let mlmodel = UTType(filenameExtension: "mlmodel", conformingTo: .item)!
}
