//
//  SlidingPad.swift
//  ROV Control
//
//  Created by Kam Ho Leung on 2/2/2024.
//

import SwiftUI
import CoreHaptics

struct SlidingPad: View {
    @Binding var horizontalValue : CGFloat
    @Binding var verticalValue : CGFloat
    let horizontalMax : CGFloat
    let verticalMax : CGFloat
    let maxValue : CGFloat = 100
    let w = 150
    let h = 150
    @State var circleLoc : CGPoint = CGPoint(x: 150/2, y: 150/2)
    var body: some View {
        
        ZStack{
            Circle()
                .position(circleLoc)
                .opacity(0.2)
            Color.clear
                .background(.ultraThinMaterial)
                
                
        }.clipShape(.rect(cornerRadius: 25.0))
            .blur(radius: 10)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ change in
                        withAnimation(){
                            
                            circleLoc = change.location
                        }
                        let translation = change.translation
                        var w = translation.width
                        var h = translation.height
                        if w > maxValue{
                            w = maxValue
                        }else if w < -maxValue{
                            w = -maxValue
                        }
                        if h > maxValue{
                            h = maxValue
                        }else if h < -maxValue{
                            h = -maxValue
                        }
                        horizontalValue = (w / self.maxValue) * horizontalMax
                        verticalValue = -(h / self.maxValue) * verticalMax //vertical is flipped
                        print(horizontalValue,verticalValue)
                        if translation.height.truncatingRemainder(dividingBy: 2) == 0 || translation.width.truncatingRemainder(dividingBy: 2) == 0{
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        }
                        
                    })
                    .onEnded({ _ in
                        horizontalValue = 0
                        verticalValue = 0
                        withAnimation(){
                            circleLoc = CGPoint(x: w/2, y: h/2)
                        }
                    })
            )
            .frame(maxWidth: 150, maxHeight: 150)
    }

}
