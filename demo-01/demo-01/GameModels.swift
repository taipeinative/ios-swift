import Foundation

enum Difficulty: String, CaseIterable, Codable {
    case easy
    case normal
    case hard

    var title: String {
        switch self {
        case .easy: return "簡單"
        case .normal: return "普通"
        case .hard: return "困難"
        }
    }
}

struct GameSettings {
    var volume: Double = 0.6
    var difficulty: Difficulty = .normal
    var penaltyEnabled: Bool = true
}

enum PassportPatternKind {
    case numeric9
    case alpha2Numeric8
    case alpha2Numeric7
    case alpha1Numeric3Alpha1Alpha4
}

enum Nation: String, CaseIterable {
    case taiwan = "台灣"
    case hongKong = "香港"
    case china = "中國"
    case japan = "日本"
    case southKorea = "韓國"

    var key: String {
        switch self {
        case .taiwan: return "taiwan"
        case .hongKong: return "hongKong"
        case .china: return "china"
        case .japan: return "japan"
        case .southKorea: return "southKorea"
        }
    }

    init?(key: String) {
        switch key {
        case "taiwan": self = .taiwan
        case "hongKong": self = .hongKong
        case "china": self = .china
        case "japan": self = .japan
        case "southKorea": self = .southKorea
        default: return nil
        }
    }

    var cities: [String] {
        switch self {
        case .taiwan:
            return ["Taipei", "Taoyuan", "Taichung", "Tainan", "Kaoshiung"]
        case .hongKong:
            return ["Hong Kong"]
        case .china:
            return ["Beijing", "Tianjin", "Shanghai", "Chongqing", "Guangzhou"]
        case .japan:
            return ["Tokyo", "Yokohama", "Nagoya", "Osaka", "Fukuoka"]
        case .southKorea:
            return ["Seoul", "Incheon", "Daegu", "Gwangju", "Busan"]
        }
    }

    var passportStyleName: String {
        switch self {
        case .taiwan: return "台灣護照"
        case .hongKong: return "香港特區護照"
        case .china: return "中國護照"
        case .japan: return "日本護照"
        case .southKorea: return "韓國護照"
        }
    }

    var passportPatternKind: PassportPatternKind {
        switch self {
        case .taiwan, .china:
            return .numeric9
        case .hongKong:
            return .alpha2Numeric8
        case .japan:
            return .alpha2Numeric7
        case .southKorea:
            return .alpha1Numeric3Alpha1Alpha4
        }
    }

    var passportRuleText: String {
        switch self {
        case .taiwan:
            return "9 位數字"
        case .china:
            return "9 位數字"
        case .hongKong:
            return "2 英文字母 + 8 位數字"
        case .japan:
            return "2 英文字母 + 7 位數字"
        case .southKorea:
            return "1 英文字母 + 3 位數字 + 1 英文字母 + 4 英文字母"
        }
    }

    var passportColorText: String {
        switch self {
        case .taiwan:
            return "綠色封面"
        case .china:
            return "深紅色封面"
        case .hongKong:
            return "黑色封面"
        case .japan:
            return "亮紅色封面"
        case .southKorea:
            return "海軍藍封面"
        }
    }

    func generatePassportNumber() -> String {
        switch self {
        case .taiwan, .china:
            return String.randomDigits(count: 9)
        case .hongKong:
            return String.randomLetters(count: 2) + String.randomDigits(count: 8)
        case .japan:
            return String.randomLetters(count: 2) + String.randomDigits(count: 7)
        case .southKorea:
            return String.randomLetters(count: 1) + String.randomDigits(count: 3) + String.randomLetters(count: 1) + String.randomLetters(count: 4)
        }
    }

    func validatePassportNumber(_ input: String) -> Bool {
        switch self {
        case .taiwan, .china:
            return input.count == 9 && input.allSatisfy {$0.isNumber}
        case .hongKong:
            guard input.count == 10 else { return false }
            let chars = Array(input.uppercased())
            return chars[0].isASCIIUppercaseLetter && chars[1].isASCIIUppercaseLetter && chars[2...9].allSatisfy {$0.isNumber}
        case .japan:
            guard input.count == 9 else { return false }
            let chars = Array(input.uppercased())
            return chars[0].isASCIIUppercaseLetter && chars[1].isASCIIUppercaseLetter && chars[2...8].allSatisfy {$0.isNumber}
        case .southKorea:
            guard input.count == 9 else { return false }
            let chars = Array(input.uppercased())
            return chars[0].isASCIIUppercaseLetter && chars[1...3].allSatisfy {$0.isNumber} && chars[4].isASCIIUppercaseLetter && chars[5...8].allSatisfy {$0.isASCIIUppercaseLetter}
        }
    }
}

enum TravellerSex: String, CaseIterable, Codable {
    case male = "男"
    case female = "女"
}

enum VisaType: String, CaseIterable {
    case entryPermit = "台灣入出境許可證"
    case workVisa = "工作簽證"

    var purposes: [String] {
        switch self {
        case .entryPermit:
            return ["探親", "旅遊", "短期商務"]
        case .workVisa:
            return ["技術工作", "駐點任務", "教育交流"]
        }
    }
}

struct PassportDocument {
    var name: String
    var passportNumber: String
    var nationality: Nation
    var bornPlace: String
    var sex: TravellerSex
    var expiryDate: Date
}

struct VisaDocument {
    var type: VisaType
    var name: String
    var passportNumber: String
    var sex: TravellerSex
    var bornPlace: String
    var expiryDate: Date
    var purpose: String
}

struct Traveller {
    var name: String
    var sex: TravellerSex
    var declaredNationality: Nation
    var portraitIndex: Int
    var passport: PassportDocument?
    var visa: VisaDocument?
}

enum Decision {
    case allow
    case reject
}

struct RoundResult {
    var isCorrect: Bool
    var scoreDelta: Int
    var reason: String
}

enum RuleFailure: String {
    case noPassport = "無護照"
    case nameMismatch = "姓名不符"
    case expiryInvalid = "證件效期不足六個月"
    case noVisa = "無簽證"
    case passportNumberInvalid = "護照號碼格式錯誤"
    case sexMismatch = "性別不符"
    case cityMismatch = "出生地不符"
    case passportMismatch = "護照國籍不符"

    var description: String { rawValue }
}

enum GameRuleEngine {
    static func checkFailures(for traveller: Traveller, currentDate: Date, difficulty: Difficulty) -> [RuleFailure] {
        guard let passport = traveller.passport else {
            return [.noPassport]
        }

        var failures: [RuleFailure] = []
        let threshold = Calendar.current.date(byAdding: .month, value: 6, to: currentDate) ?? currentDate

        if passport.name != traveller.name {
            appendUnique(.nameMismatch, to: &failures)
        }

        if passport.expiryDate < threshold {
            appendUnique(.expiryInvalid, to: &failures)
        }

        if !passport.nationality.validatePassportNumber(passport.passportNumber) {
            appendUnique(.passportNumberInvalid, to: &failures)
        }

        if passport.sex != traveller.sex {
            appendUnique(.sexMismatch, to: &failures)
        }

        if difficulty == .hard && !traveller.declaredNationality.cities.contains(passport.bornPlace) {
            appendUnique(.cityMismatch, to: &failures)
        }

        if difficulty == .hard && passport.nationality != traveller.declaredNationality {
            appendUnique(.passportMismatch, to: &failures)
        }

        if traveller.declaredNationality != .taiwan {
            guard let visa = traveller.visa else {
                appendUnique(.noVisa, to: &failures)
                return failures
            }

            if visa.expiryDate < threshold {
                appendUnique(.expiryInvalid, to: &failures)
            }

            if visa.name != passport.name {
                appendUnique(.nameMismatch, to: &failures)
            }

            if visa.passportNumber != passport.passportNumber {
                appendUnique(.passportNumberInvalid, to: &failures)
            }

            if visa.sex != passport.sex {
                appendUnique(.sexMismatch, to: &failures)
            }

            if difficulty == .hard && visa.bornPlace != passport.bornPlace {
                appendUnique(.cityMismatch, to: &failures)
            }
        }

        return failures
    }

    static func review(
        traveller: Traveller,
        decision: Decision,
        currentDate: Date,
        difficulty: Difficulty,
        penaltyEnabled: Bool
    ) -> RoundResult {
        let failures = checkFailures(for: traveller, currentDate: currentDate, difficulty: difficulty)
        let shouldAllow = failures.isEmpty
        let playerAllowed = decision == .allow
        let isCorrect = shouldAllow == playerAllowed

        if isCorrect {
            return RoundResult(isCorrect: true, scoreDelta: 1, reason: "判定正確")
        }

        let delta = penaltyEnabled ? -2 : 0
        let reason = failures.first?.description ?? "判定錯誤"
        return RoundResult(isCorrect: false, scoreDelta: delta, reason: reason)
    }

    private static func appendUnique(_ failure: RuleFailure, to failures: inout [RuleFailure]) {
        if !failures.contains(failure) {
            failures.append(failure)
        }
    }
}

private enum TravellerIssue: String, CaseIterable {
    case nameMismatch
    case expiryInvalid
    case noPassport
    case passportCountryPatternMismatch
    case passportCharacterSwap
    case sexMismatch
    case noVisa
    case cityMismatch
    case passportMismatch
}

struct NameVariant: Codable {
    let name: String
    let typo: String
}

private struct RegionNamePool: Codable {
    let nation: String
    let male: [NameVariant]
    let female: [NameVariant]
}

private struct TravellerNameDataset: Codable {
    let regions: [RegionNamePool]
}

enum TravellerFactory {
    private static let fallbackName = NameVariant(name: "未知旅客", typo: "末知旅客")

    static func generateTraveller(currentDate: Date, difficulty: Difficulty) -> Traveller {
        let nationality = Nation.allCases.randomElement() ?? .taiwan
        let sex = TravellerSex.allCases.randomElement() ?? .male
        let nameVariant = TravellerNameRepository.shared.randomName(for: nationality, sex: sex) ?? fallbackName
        let city = nationality.cities.randomElement() ?? "Unknown"
        let passportNumber = nationality.generatePassportNumber()

        let validPassportExpiry = Calendar.current.date(byAdding: .day, value: Int.random(in: 220...900), to: currentDate) ?? currentDate
        var passport: PassportDocument? = PassportDocument(
            name: nameVariant.name,
            passportNumber: passportNumber,
            nationality: nationality,
            bornPlace: city,
            sex: sex,
            expiryDate: validPassportExpiry
        )

        var visa: VisaDocument?
        if nationality != .taiwan {
            let visaType = VisaType.allCases.randomElement() ?? .entryPermit
            let validVisaExpiry = Calendar.current.date(byAdding: .day, value: Int.random(in: 220...700), to: currentDate) ?? currentDate
            visa = VisaDocument(
                type: visaType,
                name: nameVariant.name,
                passportNumber: passportNumber,
                sex: sex,
                bornPlace: city,
                expiryDate: validVisaExpiry,
                purpose: visaType.purposes.randomElement() ?? "旅遊"
            )
        }

        var traveller = Traveller(
            name: nameVariant.name,
            sex: sex,
            declaredNationality: nationality,
            portraitIndex: Int.random(in: 0...9),
            passport: passport,
            visa: visa
        )

        injectPossibleIssue(
            into: &traveller,
            difficulty: difficulty,
            currentDate: currentDate,
            nationality: nationality,
            nameVariant: nameVariant
        )

        return traveller
    }

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        return formatter.string(from: date)
    }

    private static func injectPossibleIssue(
        into traveller: inout Traveller,
        difficulty: Difficulty,
        currentDate: Date,
        nationality: Nation,
        nameVariant: NameVariant
    ) {
        let config = ErrorConfigRepository.shared.config(for: difficulty)
        guard rollByPercent(config.falseChance) else {
            return
        }

        let possible = possibleIssues(for: difficulty, nationality: nationality)
        guard let issue = pickIssueByWeight(possible: possible, weights: config.errorWeights) else { return }

        apply(issue: issue, to: &traveller, currentDate: currentDate, nationality: nationality, typoName: nameVariant.typo)
    }

    private static func possibleIssues(for difficulty: Difficulty, nationality: Nation) -> [TravellerIssue] {
        var issues: [TravellerIssue] = [.nameMismatch, .expiryInvalid, .noPassport]

        if difficulty == .normal || difficulty == .hard {
            issues += [.passportCountryPatternMismatch, .sexMismatch]
            if nationality != .taiwan {
                issues.append(.noVisa)
            }
        }

        if difficulty == .hard {
            issues += [.passportCharacterSwap, .cityMismatch, .passportMismatch]
        }

        return issues
    }

    private static func apply(
        issue: TravellerIssue,
        to traveller: inout Traveller,
        currentDate: Date,
        nationality: Nation,
        typoName: String
    ) {
        switch issue {
        case .nameMismatch:
            traveller.passport?.name = typoName
            traveller.visa?.name = typoName

        case .expiryInvalid:
            let invalidDate = Calendar.current.date(byAdding: .day, value: Int.random(in: -90...170), to: currentDate) ?? currentDate
            if traveller.passport != nil {
                traveller.passport?.expiryDate = invalidDate
            } else if traveller.visa != nil {
                traveller.visa?.expiryDate = invalidDate
            }

        case .noPassport:
            traveller.passport = nil
            traveller.visa = nil

        case .passportCountryPatternMismatch:
            guard let wrongNation = Nation.allCases.filter({ $0.passportPatternKind != nationality.passportPatternKind }).randomElement() else {
                return
            }
            let wrongNumber = wrongNation.generatePassportNumber()
            traveller.passport?.passportNumber = wrongNumber
            traveller.visa?.passportNumber = wrongNumber

        case .passportCharacterSwap:
            guard let original = traveller.passport?.passportNumber else { return }
            let swapped = mutatePassportNumberForHard(original)
            traveller.passport?.passportNumber = swapped
            traveller.visa?.passportNumber = swapped

        case .sexMismatch:
            let wrongSex: TravellerSex = traveller.sex == .male ? .female : .male
            traveller.passport?.sex = wrongSex
            traveller.visa?.sex = wrongSex

        case .noVisa:
            if nationality != .taiwan {
                traveller.visa = nil
            }

        case .cityMismatch:
            let invalidCity = Nation.allCases
                .filter { !$0.cities.contains(where: nationality.cities.contains) || $0 != nationality }
                .flatMap{$0.cities}
                .filter { !nationality.cities.contains($0) }
                .randomElement() ?? "Unknown"
            traveller.passport?.bornPlace = invalidCity
            traveller.visa?.bornPlace = invalidCity

        case .passportMismatch:
            guard let wrongNation = Nation.allCases.filter({ $0 != nationality }).randomElement() else { return }
            let wrongNumber = wrongNation.generatePassportNumber()
            traveller.passport?.nationality = wrongNation
            traveller.passport?.passportNumber = wrongNumber
            traveller.visa?.passportNumber = wrongNumber
        }
    }

    private static func rollByPercent(_ chance: Double) -> Bool {
        let normalized = chance > 1 ? chance / 100 : chance
        guard normalized > 0 else { return false }
        return Double.random(in: 0...1) < min(normalized, 1)
    }

    private static func pickIssueByWeight(possible: [TravellerIssue], weights: [TravellerIssue: Double]) -> TravellerIssue? {
        let filtered = possible.map { ($0, max(0, weights[$0] ?? 0)) }
        let total = filtered.reduce(0) { $0 + $1.1 }
        guard total > 0 else { return nil }

        let random = Double.random(in: 0..<total)
        var running: Double = 0
        for (issue, weight) in filtered {
            running += weight
            if random < running {
                return issue
            }
        }
        return filtered.last?.0
    }

    private static func mutatePassportNumberForHard(_ original: String) -> String {
        guard !original.isEmpty else { return original }
        var chars = Array(original.uppercased())
        let idx = Int.random(in: 0..<chars.count)
        let c = chars[idx]
        if c.isNumber {
            chars[idx] = Character(String.randomLetters(count: 1))
        } else {
            chars[idx] = Character(String.randomDigits(count: 1))
        }
        return String(chars)
    }
}

private struct ErrorConfigEntry: Codable {
    let difficulty: Difficulty
    let falseChance: Double
    let error: [String: Double]

    enum CodingKeys: String, CodingKey {
        case difficulty = "Difficulty"
        case falseChance = "False chance"
        case error = "Error"
    }
}

private struct DifficultyErrorConfig {
    let falseChance: Double
    let errorWeights: [TravellerIssue: Double]
}

private final class ErrorConfigRepository {
    static let shared = ErrorConfigRepository()

    private var table: [Difficulty: DifficultyErrorConfig] = [:]

    private init() {
        loadFromBundle()
        if table.isEmpty {
            loadFallback()
        }
    }

    func config(for difficulty: Difficulty) -> DifficultyErrorConfig {
        table[difficulty] ?? defaultConfig(for: difficulty)
    }

    private func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "error_config", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([ErrorConfigEntry].self, from: data) else {
            return
        }

        var result: [Difficulty: DifficultyErrorConfig] = [:]
        for entry in entries {
            var mapped: [TravellerIssue: Double] = [:]
            for (key, value) in entry.error {
                if let issue = TravellerIssue(rawValue: key) {
                    mapped[issue] = max(0, value)
                }
            }
            result[entry.difficulty] = DifficultyErrorConfig(falseChance: entry.falseChance, errorWeights: mapped)
        }
        table = result
    }

    private func loadFallback() {
        table = [
            .easy: defaultConfig(for: .easy),
            .normal: defaultConfig(for: .normal),
            .hard: defaultConfig(for: .hard)
        ]
    }

    private func defaultConfig(for difficulty: Difficulty) -> DifficultyErrorConfig {
        switch difficulty {
        case .easy:
            return DifficultyErrorConfig(falseChance: 40, errorWeights: [
                .nameMismatch: 3,
                .expiryInvalid: 4,
                .noPassport: 2
            ])
        case .normal:
            return DifficultyErrorConfig(falseChance: 60, errorWeights: [
                .nameMismatch: 2,
                .expiryInvalid: 3,
                .noPassport: 1,
                .passportCountryPatternMismatch: 3,
                .sexMismatch: 2,
                .noVisa: 2
            ])
        case .hard:
            return DifficultyErrorConfig(falseChance: 75, errorWeights: [
                .nameMismatch: 2,
                .expiryInvalid: 2,
                .noPassport: 1,
                .passportCountryPatternMismatch: 2,
                .passportCharacterSwap: 2,
                .sexMismatch: 2,
                .noVisa: 2,
                .cityMismatch: 2,
                .passportMismatch: 2
            ])
        }
    }
}

private final class TravellerNameRepository {
    static let shared = TravellerNameRepository()

    private var table: [Nation: [TravellerSex: [NameVariant]]] = [:]

    private init() {
        loadFromBundle()
    }

    func randomName(for nation: Nation, sex: TravellerSex) -> NameVariant? {
        table[nation]?[sex]?.randomElement()
    }

    private func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "traveler_names", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dataset = try? JSONDecoder().decode(TravellerNameDataset.self, from: data) else {
            loadFallback()
            return
        }

        var result: [Nation: [TravellerSex: [NameVariant]]] = [:]

        for region in dataset.regions {
            guard let nation = Nation(key: region.nation) else { continue }
            result[nation] = [
                .male: region.male,
                .female: region.female
            ]
        }

        table = result.isEmpty ? table : result
        if table.isEmpty {
            loadFallback()
        }
    }

    private func loadFallback() {
        let genericMale = [NameVariant(name: "陳志明", typo: "陳智明")]
        let genericFemale = [NameVariant(name: "林怡君", typo: "林宜君")]

        var fallback: [Nation: [TravellerSex: [NameVariant]]] = [:]
        Nation.allCases.forEach { nation in
            fallback[nation] = [
                .male: genericMale,
                .female: genericFemale
            ]
        }
        table = fallback
    }
}

private extension String {
    static func randomDigits(count: Int) -> String {
        (0..<count).map { _ in String(Int.random(in: 0...9)) }.joined()
    }

    static func randomLetters(count: Int) -> String {
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        return (0..<count).map { _ in String(letters.randomElement() ?? "A") }.joined()
    }
}

private extension Character {
    var isASCIIUppercaseLetter: Bool {
        guard let scalar = unicodeScalars.first, unicodeScalars.count == 1 else { return false }
        return scalar.value >= 65 && scalar.value <= 90
    }
}
