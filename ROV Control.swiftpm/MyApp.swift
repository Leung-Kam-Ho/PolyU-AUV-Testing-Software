import SwiftUI

@main
struct MyApp: App {
    @ObservedObject var settings = Settings()
    @ObservedObject var inputmanager = InputManager()
    var body: some Scene {
        WindowGroup {
            ZStack{
                BackgroundView()
                    .ignoresSafeArea(.all)
                ContentView()
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .environmentObject(inputmanager)
            .environmentObject(settings)
        }
    }
}
