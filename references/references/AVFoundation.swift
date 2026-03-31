import AVFoundation
import SwiftUI

struct AVView: View {
    @State private var speech: String = "This is a generated speech."
    @State private var speechLang: String = "en-US"
    @State private var speechRate: Float = AVSpeechUtteranceDefaultSpeechRate
    @State private var speechPitch: Float = 1.0
    @State private var showSettings = false
    
    let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                Button(action: {
                    let utterance = AVSpeechUtterance(string: speech)
                    utterance.voice = AVSpeechSynthesisVoice(language: speechLang)
                    utterance.rate = speechRate
                    utterance.pitchMultiplier = speechPitch
                    synthesizer.speak(utterance)
                }) {
                    Label("", systemImage: "speaker.wave.2.fill")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 36))
                }
                .vSpacer(15)
                
                Menu("Language") {
                    Button("Japanese") { speechLang = "ja-JP" }
                    Button("English") { speechLang = "en-US" }
                    Button("Chinese") { speechLang = "zh-TW" }
                }
                
                Text("Current: \(speechLang)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .vSpacer(20)
                
                TextField("Speech text here", text: $speech)
                    .frame(width: 300)
                    .textFieldStyle(.roundedBorder)
                    .vSpacer(20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Gear button (top-left of screen)
            Button(action: {
                showSettings.toggle()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .padding()
            }
        }
        .sheet(isPresented: $showSettings) {
            AVSettingsView(
                speechRate: $speechRate,
                speechPitch: $speechPitch
            )
        }
    }
}

struct AVSettingsView: View {
    @Binding var speechRate: Float
    @Binding var speechPitch: Float
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.title)
                .padding()
            
            VStack {
                Text("Speed: \(String(format: "%.2f", speechRate))")
                Slider(value: $speechRate, in: 0.1...0.6)
            }
            .frame(width: 250)
            .padding()
            
            VStack {
                Text("Pitch: \(String(format: "%.2f", speechPitch))")
                Slider(value: $speechPitch, in: 0.5...2.0)
            }
            .frame(width: 250)
            .padding()
            
            Spacer()
        }
    }
}

#Preview{
    AVView()
}
