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
            
            // Subtitle Texts
            Text("可以看到 將近是20公分的深度")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.title2)
                .offset(x: 25, y: 140)
            
            // Red Stripes
            Rectangle()
                .fill(.tabasco)
                .frame(width: 390, height: 30)
                .offset(x: 65, y: 175)
                .opacity(visibility)
            
            // Headline Title
            Text("風聲鶴唳")
                .foregroundColor(.yellow)
                .fontWeight(.bold)
                .offset(x: -80, y: 175)
            
            // Headline Contents
            Text("美警告航空公司 小心鞋子炸彈")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .offset(x: 80, y: 175)
            
            // Black Background
            Rectangle()
                .fill(.black)
                .frame(width: 130, height: 30)
                .offset(x: -195, y: 175)
                .opacity(visibility)
            
            // Time Display
            Text("13:09")
                .foregroundColor(.yellow)
                .fontWeight(.heavy)
                .font(.title3)
                .offset(x: -185, y: 175)
                .tracking(3)
                .multilineTextAlignment(.center)
            
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
            
            // Currency Title - 1
            Text("美")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.callout)
                .offset(x: -222.5, y: 130)
            
            // Currency Title - 2
            Text("元")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.callout)
                .offset(x: -222.5, y: 150)
            
            // Currency Subtitle - 1
            Text("買")
                .foregroundColor(.deepBrightRed)
                .fontWeight(.medium)
                .font(.callout)
                .offset(x: -203, y: 130)
                .blur(radius: 1)
            
            Text("買")
                .foregroundColor(.white)
                .fontWeight(.medium)
                .font(.callout)
                .offset(x: -203, y: 130)
            
            // Currency Subtitle - 2
            Text("賣")
                .foregroundColor(.white)
                .fontWeight(.medium)
                .font(.callout)
                .offset(x: -203, y: 150)
            
            // Currency Contents - 1
            Text("30.298")
                .foregroundColor(.deepBrightRed)
                .fontWeight(.medium)
                .font(.callout)
                .offset(x: -163, y: 130)
            
            // Currency Contents - 2
            Text("30.301")
                .foregroundColor(.yellow)
                .fontWeight(.medium)
                .font(.callout)
                .offset(x: -163, y: 150)
            
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
            
            // Location
            Text("南投")
                .foregroundColor(.white)
                .fontWeight(.heavy)
                .offset(x: -183, y: 110)
                .tracking(15)
                .multilineTextAlignment(.center)
            
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
            
            // Thermometer - C
            Text("C")
                .foregroundColor(.deepBronzeMetal)
                .fontWeight(.heavy)
                .offset(x: 48, y: -88)
            
            // Thermometer - F
            Text("F")
                .foregroundColor(.deepBronzeMetal)
                .fontWeight(.heavy)
                .offset(x: 70, y: -90)
            
            // Hand
            Path { path in
                path.move(to: CGPoint(x: 300, y: 100))
                path.addLine(to: CGPoint(x: 350, y: 110))
                path.addLine(to: CGPoint(x: 400, y: 140))
                path.addLine(to: CGPoint(x: 395, y: 158))
                path.addLine(to: CGPoint(x: 345, y: 130))
                path.addLine(to: CGPoint(x: 315, y: 170))
                path.addLine(to: CGPoint(x: 290, y: 160))
                path.closeSubpath()
            }
            
            // Cloth
            RoundedRectangle(cornerRadius: 20)
                .fill(.asphalt)
                .frame(width: 250, height: 80)
                .rotationEffect(.degrees(22))
                .offset(x: -180, y: -110)
                .opacity(visibility)
            
            // Reporter
            Text("TVBS記者 廖容瑩")
                .foregroundColor(.black)
                .fontWeight(.bold)
                .font(.subheadline)
                .offset(x: -70, y: 110)
                .blur(radius: 2)
            
            Text("TVBS記者 廖容瑩")
                .foregroundColor(.sweetCorn)
                .fontWeight(.bold)
                .font(.subheadline)
                .offset(x: -70, y: 110)
            
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
