import SwiftUI

struct MainPage: View {
    var onNavigateToDetail: (ReviewTarget) -> Void
    var onPresentCreateNew: () -> Void
    
    var body: some View {
        ScrollView {
            HStack(alignment: .bottom) {
                Greeting()
                Level(2)
            }
            .padding(.horizontal, 35)
            
            HStack {
                SearchBarButton()
                IconButton(systemName: "line.3.horizontal.decrease.circle") { }
                IconButton(systemName: "gearshape.fill") { }
            }
            .frame(minHeight: 35)
            .padding(.horizontal, 35)
            .padding(.bottom, 20)
            

            Button(action: { }) {
                Post("武吉蛋包飯", 4.5, "憑學生證可以打折，還不錯吃...", ReviewType.location, fromDateString(text: "2025-05-30") ?? Date())
                    .padding(.horizontal, 35)
            }
            .buttonStyle(.plain)
            
            Button(action: { }) {
                Post("True North (2026)", 2.5, "Jason Ross 睽違四年的新專輯...", ReviewType.music, fromDateString(text: "2025-05-29") ?? Date())
                    .padding(.horizontal, 35)
            }
            .buttonStyle(.plain)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: onPresentCreateNew) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
            }
        }
    }
}

