import SwiftUI

struct ContentView: View {
    let visibility: Double = 1
    var body: some View {
        ZStack{
            Image(.snow)
                .resizable()
                .scaledToFit()
                .opacity(1-visibility)
            
            // Snow
            Rectangle()
                .fill(.snow)
                .frame(width: 520, height:400)
                .opacity(visibility)
            
            // Blue Stripes
            Rectangle()
                .fill(LinearGradient(
                    colors:[.morningGlory, .smalt],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 520, height: 40)
                .offset(y: 140)
                .opacity(visibility)
            
            // Red Stripes
            Rectangle()
                .fill(.tabasco)
                .frame(width: 390, height: 30)
                .offset(x: 65, y: 175)
                .opacity(visibility)
            
            // Black Background
            Rectangle()
                .fill(.black)
                .frame(width: 130, height: 30)
                .offset(x: -195, y: 175)
                .opacity(visibility)
            
            // Currency Red Background
            Rectangle()
                .fill(.deepBrightRed)
                .frame(width: 100, height: 40)
                .offset(x: -183, y: 140)
                .opacity(visibility)
            
            // Currency White Background
            Rectangle()
                .fill(.white)
                .frame(width: 80, height: 20)
                .offset(x: -173, y: 130)
                .opacity(visibility)
            
            // Location Red Background
            Path { path in
                path.move(to: CGPoint(x: 152, y: 300))
                path.addLine(to: CGPoint(x: 232, y: 300))
                path.addLine(to: CGPoint(x: 242, y: 320))
                path.addLine(to: CGPoint(x: 142, y: 320))
                path.closeSubpath()
            }
                .fill(.tabasco)
                .opacity(visibility)
            
            // Thermometer
            Path { path in
                path.move(to: CGPoint(x: 408, y: 65))
                path.addLine(to: CGPoint(x: 406, y: 215))
                path.addLine(to: CGPoint(x: 457, y: 220))
                path.addLine(to: CGPoint(x: 460, y: 62))
                path.closeSubpath()
            }
                .fill(.cinnamonRolls)
                .opacity(visibility)
        
            // Glass
            Path { path in
                path.move(to: CGPoint(x: 420, y: 145))
                path.addLine(to: CGPoint(x: 450, y: 143))
                path.addLine(to: CGPoint(x: 450, y: 147))
                path.addLine(to: CGPoint(x: 438, y: 148))
                path.addLine(to: CGPoint(x: 433, y: 217))
                path.addLine(to: CGPoint(x: 425, y: 215))
                path.addLine(to: CGPoint(x: 429, y: 148))
                path.addLine(to: CGPoint(x: 420, y: 148))
                path.closeSubpath()
            }
                .fill(.gold)
                .opacity(visibility)
            
            // Nail
            Circle()
                .fill(.beige)
                .frame(width: 8)
                .offset(x: 59, y: -122)
                .opacity(visibility)
            
            // Title
            Image(.frozen)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .offset(x: -130, y: -150)
                .opacity(visibility)
        }
    }
}

#Preview {
    ContentView()
}
