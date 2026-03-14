import SwiftUI
import Combine

struct StageView: View {
    let settings: GameSettings
    let onExit: () -> Void

    @State private var remainingSeconds: Int = 180
    @State private var score: Int = 0
    @State private var isPaused: Bool = false
    @State private var showRules: Bool = false
    @State private var showDocumentsGuide: Bool = false
    @State private var showPausePanel: Bool = false
    @State private var isTimeExpired: Bool = false
    @State private var isGameOver: Bool = false
    @State private var gameDate: Date = Date()
    @State private var currentTraveller: Traveller?
    @State private var lastRoundResult: RoundResult?

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 0) {
                    chamberSection
                        .frame(width: geo.size.width * 0.3)

                    HStack(spacing: 0) {
                        tabletopSection
                            .frame(width: geo.size.width * 0.5)
                        bookmarkSection
                            .frame(width: geo.size.width * 0.2)
                    }
                    .background(Color(red: 0.33, green: 0.28, blue: 0.22))
                }

                headerBar
                    .padding(.top, 10)
                    .padding(.trailing, 10)

                if showRules {
                    overlayPanel(title: "規則") {
                        Text(rulesText)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                    }
                }

                if showDocumentsGuide {
                    overlayPanel(title: "文件") {
                        documentsGuideView
                    }
                }

                if showPausePanel {
                    overlayPanel(title: "已暫停") {
                        VStack(spacing: 10) {
                            PixelButton(title: "繼續") {
                                showPausePanel = false
                                isPaused = false
                            }
                            .frame(width: 180)

                            PixelButton(title: "回主選單") {
                                onExit()
                            }
                            .frame(width: 180)
                        }
                    }
                }

                if isGameOver {
                    overlayPanel(title: "結算") {
                        VStack(spacing: 12) {
                            Text("總分：\(score)")
                                .font(.system(size: 28, weight: .black, design: .monospaced))
                                .foregroundStyle(.yellow)

                            PixelButton(title: "回主選單") {
                                onExit()
                            }
                            .frame(width: 180)
                        }
                    }
                }
            }
            .onAppear {
                startGameIfNeeded()
            }
            .onReceive(timer) { _ in
                guard !isPaused && !isGameOver && !showDocumentsGuide else { return }
                guard remainingSeconds > 0 else { return }

                remainingSeconds -= 1
                if remainingSeconds == 0 {
                    isTimeExpired = true
                    if currentTraveller == nil {
                        isGameOver = true
                    }
                }
            }
        }
    }

    private var rulesText: String {
        """
        移民檢查手冊（\(settings.difficulty.title)）：
        1. 旅客必須有護照。
        2. 護照（與簽證）效期必須距離本日至少 6 個月。
        3. 非台灣旅客必須有簽證。
        4. 檢查姓名、護照號碼、性別。
        5. 困難模式再檢查：出生地、護照國籍不符（例：中國公民持韓國護照）。

        錯誤池：
        簡單：姓名、到期日、無護照
        普通：簡單 + 護照號碼（國別格式錯誤）、性別、無簽證
        困難：普通 + 護照號碼字元置換（數字/字母）、出生地、護照國籍不符
        """
    }

    private var chamberSection: some View {
        VStack(spacing: 12) {
            Text("審查室")
                .font(.system(size: 24, weight: .black, design: .monospaced))
                .foregroundStyle(.yellow)
                .padding(.top, 18)

            if let traveller = currentTraveller {
                PixelPortraitView(sex: traveller.sex, index: traveller.portraitIndex)
                    .frame(height: 215)
                    .padding(.horizontal, 12)
                    .padding(.top, 6)

                PixelPanel(title: "旅客資料") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("姓名：\(traveller.name)")
                        Text("性別：\(traveller.sex.rawValue)")
                        Text("申報國籍：\(traveller.declaredNationality.rawValue)")
                        Text("日期：\(TravellerFactory.formatDate(gameDate))")
                    }
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            } else {
                Spacer()

                if let result = lastRoundResult {
                    PixelPanel(title: "上一輪結果") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(result.isCorrect ? "判定正確" : "判定錯誤")
                                .foregroundStyle(result.isCorrect ? Color.green : Color.red)
                            Text("分數變化：\(result.scoreDelta >= 0 ? "+\(result.scoreDelta)" : "\(result.scoreDelta)")")
                            Text("原因：\(result.reason)")
                        }
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                } else {
                    Text("等待旅客...")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                }

                Spacer()
            }
        }
        .background(Color(red: 0.21, green: 0.24, blue: 0.27))
        .overlay(
            Rectangle().stroke(Color.black.opacity(0.4), lineWidth: 2)
        )
    }

    private var tabletopSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("桌面文件")
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .foregroundStyle(.yellow)
                    .padding(.top, 16)

                if let traveller = currentTraveller {
                    if let passport = traveller.passport {
                        PassportCardView(passport: passport)
                    }

                    if traveller.declaredNationality != .taiwan {
                        if let visa = traveller.visa {
                            VisaCardView(visa: visa)
                        }
                    }
                } else {
                    Text("旅客已離開，等待下一位...")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 20)
        }
    }

    private var bookmarkSection: some View {
        VStack(alignment: .trailing, spacing: 14) {
            Spacer().frame(height: 68)

            bookmarkButton(title: "規則", color: .brown) {
                showDocumentsGuide = false
                showRules.toggle()
            }

            bookmarkButton(title: "文件", color: .orange) {
                showRules = false
                showDocumentsGuide.toggle()
            }

            bookmarkButton(title: "允許", color: .green) {
                judgeCurrentTraveller(with: .allow)
            }
            .disabled(currentTraveller == nil || isGameOver)

            bookmarkButton(title: "拒絕", color: .red) {
                judgeCurrentTraveller(with: .reject)
            }
            .disabled(currentTraveller == nil || isGameOver)

            Spacer()
        }
        .padding(.trailing, 0)
    }

    private var documentsGuideView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("護照號碼規則")
                    .font(.system(size: 22, weight: .black, design: .monospaced))
                    .foregroundStyle(.yellow)

                ForEach(Nation.allCases, id: \.self) { nation in
                    Text("• \(nation.rawValue)：\(nation.passportRuleText)｜\(nation.passportColorText)")
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                }

                Text("\n有效國家 / 城市")
                    .font(.system(size: 22, weight: .black, design: .monospaced))
                    .foregroundStyle(.yellow)

                ForEach(Nation.allCases, id: \.self) { nation in
                    Text("• \(nation.rawValue)：\(nation.cities.joined(separator: "、"))")
                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }

    private var headerBar: some View {
        HStack(spacing: 10) {
            Text("剩餘：\(formatTime(remainingSeconds))")
                .font(.system(size: 17, weight: .black, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.5))
                .overlay(Rectangle().stroke(Color.white.opacity(0.9), lineWidth: 2))

            Text("分數：\(score)")
                .font(.system(size: 17, weight: .black, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.5))
                .overlay(Rectangle().stroke(Color.white.opacity(0.9), lineWidth: 2))

            Button {
                isPaused = true
                showPausePanel = true
            } label: {
                Text("暫停")
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.blue.opacity(0.8))
                    .overlay(Rectangle().stroke(Color.white.opacity(0.95), lineWidth: 2))
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func overlayPanel<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        Color.black.opacity(0.42)
            .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.system(size: 30, weight: .black, design: .monospaced))
                    .foregroundStyle(.yellow)
                Spacer()
                Button("關閉") {
                    showRules = false
                    showDocumentsGuide = false
                    if showPausePanel {
                        isPaused = false
                    }
                    showPausePanel = false
                }
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .buttonStyle(.plain)
                .foregroundStyle(.white)
            }

            content()
        }
        .padding(20)
        .frame(maxWidth: 760)
        .background(Color(red: 0.16, green: 0.17, blue: 0.2))
        .overlay(
            Rectangle().stroke(Color.white.opacity(0.9), lineWidth: 3)
        )
    }

    private func bookmarkButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .black, design: .monospaced))
                .foregroundStyle(.white)
                .frame(width: 120, alignment: .center)
                .padding(.vertical, 12)
                .background(color.opacity(0.85))
                .overlay(Rectangle().stroke(Color.white.opacity(0.95), lineWidth: 2))
                .offset(x: 8)
        }
        .buttonStyle(.plain)
    }

    private func formatTime(_ seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d", min, sec)
    }

    private func startGameIfNeeded() {
        guard currentTraveller == nil && !isGameOver else { return }
        gameDate = Date()
        currentTraveller = TravellerFactory.generateTraveller(currentDate: gameDate, difficulty: settings.difficulty)
    }

    private func judgeCurrentTraveller(with decision: Decision) {
        guard let traveller = currentTraveller else { return }

        let result = GameRuleEngine.review(
            traveller: traveller,
            decision: decision,
            currentDate: gameDate,
            difficulty: settings.difficulty,
            penaltyEnabled: settings.penaltyEnabled
        )

        score += result.scoreDelta
        lastRoundResult = result
        currentTraveller = nil

        if isTimeExpired {
            isGameOver = true
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            guard !isGameOver else { return }
            currentTraveller = TravellerFactory.generateTraveller(currentDate: gameDate, difficulty: settings.difficulty)
        }
    }
}

struct PixelPortraitView: View {
    let sex: TravellerSex
    let index: Int

    private var style: PortraitStyle {
        let collection = sex == .male ? PortraitStyle.male : PortraitStyle.female
        return collection[index % collection.count]
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.25))
                .overlay(Rectangle().stroke(Color.white.opacity(0.9), lineWidth: 2))

            VStack(spacing: 6) {
                ZStack(alignment: .center) {
                    Circle()
                        .fill(style.hair.opacity(0.95))
                        .frame(width: 118, height: 118)

                    Circle()
                        .fill(style.skin)
                        .frame(width: 100, height: 100)
                        .offset(y: 5)

                    RoundedRectangle(cornerRadius: 16)
                        .fill(style.hair)
                        .frame(width: 106, height: 34)
                        .offset(y: -32)

                    RoundedRectangle(cornerRadius: 12)
                        .fill(style.hair)
                        .frame(width: 12, height: 46)
                        .offset(x: -42, y: -2)

                    RoundedRectangle(cornerRadius: 12)
                        .fill(style.hair)
                        .frame(width: 12, height: 46)
                        .offset(x: 42, y: -2)

                    HStack(spacing: 24) {
                        Circle().fill(style.eye).frame(width: 8, height: 8)
                        Circle().fill(style.eye).frame(width: 8, height: 8)
                    }
                    .offset(y: -2)

                    Capsule()
                        .fill(Color.black.opacity(0.45))
                        .frame(width: style.mouthWidth, height: 4)
                        .offset(y: 18)
                }
                .padding(.top, 16)

                RoundedRectangle(cornerRadius: 10)
                    .fill(style.shirt)
                    .frame(width: 140, height: 78)
                    .overlay(
                        Rectangle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 22, height: 18)
                            .offset(y: -18)
                    )
            }
        }
        .clipped()
    }
}

private struct PortraitStyle {
    let skin: Color
    let hair: Color
    let shirt: Color
    let eye: Color
    let mouthWidth: CGFloat

    static let male: [PortraitStyle] = [
        .init(skin: Color(red: 0.95, green: 0.79, blue: 0.67), hair: Color(red: 0.15, green: 0.15, blue: 0.16), shirt: .blue, eye: .black, mouthWidth: 20),
        .init(skin: Color(red: 0.92, green: 0.73, blue: 0.6), hair: Color(red: 0.3, green: 0.16, blue: 0.08), shirt: .green, eye: .black, mouthWidth: 16),
        .init(skin: Color(red: 0.85, green: 0.63, blue: 0.48), hair: Color(red: 0.42, green: 0.28, blue: 0.15), shirt: .indigo, eye: .black, mouthWidth: 18),
        .init(skin: Color(red: 0.75, green: 0.55, blue: 0.41), hair: Color(red: 0.08, green: 0.08, blue: 0.09), shirt: .brown, eye: .black, mouthWidth: 22),
        .init(skin: Color(red: 0.96, green: 0.83, blue: 0.7), hair: Color(red: 0.56, green: 0.44, blue: 0.17), shirt: .cyan, eye: .black, mouthWidth: 19),
        .init(skin: Color(red: 0.88, green: 0.71, blue: 0.56), hair: Color(red: 0.14, green: 0.14, blue: 0.14), shirt: .mint, eye: .black, mouthWidth: 20),
        .init(skin: Color(red: 0.82, green: 0.62, blue: 0.47), hair: Color(red: 0.37, green: 0.21, blue: 0.08), shirt: .teal, eye: .black, mouthWidth: 14),
        .init(skin: Color(red: 0.74, green: 0.56, blue: 0.45), hair: Color(red: 0.16, green: 0.1, blue: 0.1), shirt: .orange, eye: .black, mouthWidth: 18),
        .init(skin: Color(red: 0.9, green: 0.72, blue: 0.59), hair: Color(red: 0.32, green: 0.2, blue: 0.1), shirt: .purple, eye: .black, mouthWidth: 16),
        .init(skin: Color(red: 0.97, green: 0.84, blue: 0.72), hair: Color(red: 0.09, green: 0.09, blue: 0.11), shirt: .red, eye: .black, mouthWidth: 21)
    ]

    static let female: [PortraitStyle] = [
        .init(skin: Color(red: 0.97, green: 0.82, blue: 0.7), hair: Color(red: 0.21, green: 0.14, blue: 0.08), shirt: .pink, eye: .black, mouthWidth: 14),
        .init(skin: Color(red: 0.92, green: 0.75, blue: 0.62), hair: Color(red: 0.11, green: 0.11, blue: 0.12), shirt: .purple, eye: .black, mouthWidth: 16),
        .init(skin: Color(red: 0.86, green: 0.64, blue: 0.5), hair: Color(red: 0.53, green: 0.34, blue: 0.19), shirt: .orange, eye: .black, mouthWidth: 15),
        .init(skin: Color(red: 0.76, green: 0.58, blue: 0.45), hair: Color(red: 0.16, green: 0.08, blue: 0.08), shirt: .indigo, eye: .black, mouthWidth: 13),
        .init(skin: Color(red: 0.95, green: 0.82, blue: 0.71), hair: Color(red: 0.62, green: 0.44, blue: 0.2), shirt: .green, eye: .black, mouthWidth: 17),
        .init(skin: Color(red: 0.89, green: 0.69, blue: 0.55), hair: Color(red: 0.14, green: 0.14, blue: 0.14), shirt: .mint, eye: .black, mouthWidth: 12),
        .init(skin: Color(red: 0.84, green: 0.64, blue: 0.5), hair: Color(red: 0.36, green: 0.2, blue: 0.1), shirt: .teal, eye: .black, mouthWidth: 14),
        .init(skin: Color(red: 0.78, green: 0.57, blue: 0.42), hair: Color(red: 0.1, green: 0.09, blue: 0.11), shirt: .brown, eye: .black, mouthWidth: 16),
        .init(skin: Color(red: 0.9, green: 0.73, blue: 0.6), hair: Color(red: 0.46, green: 0.3, blue: 0.16), shirt: .blue, eye: .black, mouthWidth: 15),
        .init(skin: Color(red: 0.96, green: 0.83, blue: 0.71), hair: Color(red: 0.2, green: 0.13, blue: 0.09), shirt: .cyan, eye: .black, mouthWidth: 13)
    ]
}

struct PassportCardView: View {
    let passport: PassportDocument

    private var styleColor: Color {
        switch passport.nationality {
        case .taiwan: return Color(red: 0.13, green: 0.44, blue: 0.19)
        case .china: return Color(red: 0.42, green: 0.07, blue: 0.09)
        case .hongKong: return Color(red: 0.06, green: 0.06, blue: 0.07)
        case .japan: return Color(red: 0.83, green: 0.12, blue: 0.12)
        case .southKorea: return Color(red: 0.08, green: 0.17, blue: 0.42)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(passport.nationality.passportStyleName)
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundStyle(.yellow)

            documentRow(label: "姓名", value: passport.name)
            documentRow(label: "護照號碼", value: passport.passportNumber)
            documentRow(label: "國籍", value: passport.nationality.rawValue)
            documentRow(label: "出生地", value: passport.bornPlace)
            documentRow(label: "性別", value: passport.sex.rawValue)
            documentRow(label: "到期日", value: TravellerFactory.formatDate(passport.expiryDate))
        }
        .padding(12)
        .background(styleColor.opacity(0.95))
        .overlay(Rectangle().stroke(Color.white.opacity(0.95), lineWidth: 2))
    }

    @ViewBuilder
    private func documentRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text("\(label)：")
                .frame(width: 90, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.system(size: 15, weight: .bold, design: .monospaced))
        .foregroundStyle(.white)
    }
}

struct VisaCardView: View {
    let visa: VisaDocument

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(visa.type.rawValue)
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundStyle(.yellow)

            documentRow(label: "姓名", value: visa.name)
            documentRow(label: "護照號碼", value: visa.passportNumber)
            documentRow(label: "性別", value: visa.sex.rawValue)
            documentRow(label: "出生地", value: visa.bornPlace)
            documentRow(label: "到期日", value: TravellerFactory.formatDate(visa.expiryDate))
            documentRow(label: "入境目的", value: visa.purpose)
        }
        .padding(12)
        .background(Color(red: 0.2, green: 0.4, blue: 0.26).opacity(0.92))
        .overlay(Rectangle().stroke(Color.white.opacity(0.95), lineWidth: 2))
    }

    @ViewBuilder
    private func documentRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text("\(label)：")
                .frame(width: 90, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.system(size: 15, weight: .bold, design: .monospaced))
        .foregroundStyle(.white)
    }
}
