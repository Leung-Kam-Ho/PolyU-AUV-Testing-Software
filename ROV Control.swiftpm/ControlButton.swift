import SwiftUI

struct ControlButton : View{
    var selectedColor : Color = .primary
    let icon : String
    var click_action : (() -> Void)? = nil
    var press_action : (() -> Void)? = nil
    var release_action : (() -> Void)? = nil
    var body: some View{
        Button(action:{
            if let action = click_action{
                action()
            }
        }){
            ZStack{
                Color.clear
                    .background(.thickMaterial)

                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundStyle(selectedColor)
                    .bold()
                    
            }.clipShape(.rect(cornerRadius: 25.0))
        }
        .pressAction(onPress: {
            if let action = press_action{
                action()
            }
        }, onRelease: {
            if let action = release_action{
                action()
            }
        })
    }
}


struct PressActions: ViewModifier {
   var onPress: () -> Void
   var onRelease: () -> Void
   
   func body(content: Content) -> some View {
       content
           .simultaneousGesture(
               DragGesture(minimumDistance: 0)
                   .onChanged({ _ in
                       onPress()
                   })
                   .onEnded({ _ in
                       onRelease()
                   })
           )
   }
}

extension View {
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}
