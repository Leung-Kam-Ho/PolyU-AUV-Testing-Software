import SwiftUI

struct CameraView : View{
    let image : UIImage
    let mask : UIImage?
    var body : some View{
        
        Image(uiImage: image)
            .resizable()
            .background(.thickMaterial)
            .overlay(content:{
                if let mask = mask{
                    Image(uiImage: mask)
                        .resizable()
                }
                
            })
        
        
    }
}
