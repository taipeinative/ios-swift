import Foundation
import SwiftUI

extension Color {
    var toHexString: String {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        if let components = uiColor.cgColor.components {
            let r = Int((components[0] * 255).rounded())
            let g = Int((components[1] * 255).rounded())
            let b = Int((components.count >= 3 ? components[2] : components[0]) * 255.0)
            return String(format: "#%02X%02X%02X", r, g, b)
        }
        #endif
        return "#FFFFFF"
    }
}

func formatInteger(val: Double) -> String {
    return val.formatted(.number.precision(.fractionLength(0)))
}

func formatDouble(val: Double) -> String {
    return val.formatted(.number.precision(.fractionLength(1)))
}

struct BindingView: View {
    @State private var isOn: Bool = true
    @State private var sliderVal: Double = 0
    @State private var sliderFromVal: Double = 0
    @State private var sliderToVal: Double = 2
    @State private var imageColor: Color = Color.white
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image(.doodle)
                    .resizable()
                    .background(imageColor)
                    .frame(width: 300, height: 100 * (1 + sliderVal))
                    .opacity(isOn ? 1 : 0)
                
                Rectangle()
                    .foregroundStyle(.white)
                    .frame(height: max(200 - 100 * (1 + sliderVal), 0))
                
                Group {
                    Toggle("狀態：\(isOn ? "顯示" : "隱藏")", isOn: $isOn)
                    
                    HStack {
                        Text("增高：\(formatDouble(val: sliderVal))")
                        Spacer()
                        Slider(value: $sliderVal, in:sliderFromVal...sliderToVal)
                            .frame(width: 150)
                    }
                    
                    HStack {
                        Text("上限：\(formatInteger(val: sliderToVal))")
                        Spacer()
                        Slider(value: $sliderToVal, in: 1...10, step: 1)
                            .frame(width: 150)
                            .tint(.pink)
                    }
                    
                    ColorPicker("背景：\(imageColor.toHexString)", selection: $imageColor)
                        .frame(width: 300)
                    
                    HStack {
                        Button("\\ 隨機背景 /") {
                            imageColor = Color(red: .random(in: 0...1),
                                               green: .random(in: 0...1),
                                               blue: .random(in: 0...1))
                        }
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                .frame(width: 300)
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    BindingView()
}
