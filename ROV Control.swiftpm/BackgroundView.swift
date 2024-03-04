import SwiftUI

struct BackgroundView : View{
    @EnvironmentObject var settings : Settings
    @State var scale : Double = 1.0
    var body: some View{
        let breathingBG = Color.accentColor.scaleEffect(scale)
        let dotBG = DotGridView(dotSize: 30).opacity(scale)
        let iconBG = iconBG(dotSize: 60).opacity(0.2)
        let noneBG = ZStack{}
        
        ZStack{
            Color.gray
            
            switch settings.backgroundMode{
            case .breathing : 
                breathingBG
            case .dotBreathing:
                dotBG
            case .Icon:
                dotBG
            case .none:
                noneBG
            }
            Color.clear
                .background(.thickMaterial)
            if settings.backgroundMode == .Icon{
                iconBG
            }
            
        }
        .onAppear(perform: {
            animationActivate()
        })
        .onChange(of: settings.backgroundMode, { _, _ in 
            animationActivate()
        })
        

    }
    func animationActivate(){
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true),{
            scale = 1.5 - scale
        })
    }
}


//Background here
struct DotGridView : View{
    let dotSize : CGFloat 
    @State var opacityValue : Double = 0
    
    var body: some View{
        GeometryReader{ g in
            let width = g.size.width
            let height = g.size.height
            let columns = Int(width/(dotSize*2))
            let rows = Int(height/(dotSize*2))
            
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: dotSize){
                
                
                ForEach(0..<rows, id:\.self){ row in 
                    
                    
                    HStack(alignment: .center,spacing: dotSize){
                        
                        ForEach(0..<columns, id:\.self){ column in 
                            let scale = randDotSize()
                            if !((column * Int(dotSize) * 2) > Int(width)){
                                ZStack{
                                    Circle().frame(width: dotSize, height: dotSize, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        .foregroundColor(.accentColor)
                                        .scaleEffect(CGFloat(scale), anchor: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)

                                }.offset(x : CGFloat(column))
                                
                            }
                            
                        }
                        
                    }
                }
            }
            .offset(x:dotSize,y:dotSize)
            
        }
        
    }
    func randDotSize() -> Float {
        return Float.random(in: 0...2)
    }
}

//Background here
struct iconBG : View{
    let dotSize : CGFloat 
    @State var opacityValue : Double = 0
    
    var body: some View{
        GeometryReader{ g in
            let width = g.size.width
            let height = g.size.height
            let columns = Int(width/(dotSize*2)) + 1
            let rows = Int(height/(dotSize*2))
            let HandsomeFish = UIImage(imageLiteralResourceName: "handsomeFish")
            let cuteFish =  UIImage(imageLiteralResourceName: "cuteFish")
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: dotSize){
                
                
                ForEach(0..<rows, id:\.self){ row in 
                    
                    
                    
                    HStack(alignment: .center,spacing: dotSize){
                        ForEach(0..<columns, id:\.self){ column in 
                            if !((column * Int(dotSize) * 2) > Int(width)){
                                ZStack{
                                    Image(uiImage: row % 2 == 0 ? (column % 2 == 0 ? HandsomeFish : cuteFish) : (column % 2 == 1 ? HandsomeFish : cuteFish) )
                                        .resizable()
                                        .offset( x: row % 2 == 0 ? 0 : -dotSize)
                                        .frame(width: dotSize, height: dotSize, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                        .foregroundColor(.accentColor)
                                    
                                }.offset(x : CGFloat(column))
                                
                            }
                            
                        }
                        
                    }
                }
            }
            .offset(x:dotSize,y:dotSize)
            
        }
        
    }
    func randDotSize() -> Float {
        return Float.random(in: 0...2)
    }
}
