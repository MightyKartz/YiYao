enum Trigram: String, CaseIterable, Identifiable, Codable {
    case qian
    case dui
    case li
    case zhen
    case xun
    case kan
    case gen
    case kun

    var id: String { rawValue }

    init(lines: [LineValue]) {
        precondition(lines.count == 3, "A trigram must contain exactly three lines.")
        guard let trigram = Self(yangPattern: lines.map(\.isYang)) else {
            preconditionFailure("Unable to resolve trigram from line pattern.")
        }
        self = trigram
    }

    var name: String {
        switch self {
        case .qian:
            "乾"
        case .dui:
            "兑"
        case .li:
            "离"
        case .zhen:
            "震"
        case .xun:
            "巽"
        case .kan:
            "坎"
        case .gen:
            "艮"
        case .kun:
            "坤"
        }
    }

    var imageName: String {
        switch self {
        case .qian:
            "天"
        case .dui:
            "泽"
        case .li:
            "火"
        case .zhen:
            "雷"
        case .xun:
            "风"
        case .kan:
            "水"
        case .gen:
            "山"
        case .kun:
            "地"
        }
    }

    var yangPattern: [Bool] {
        switch self {
        case .qian:
            [true, true, true]
        case .dui:
            [true, true, false]
        case .li:
            [true, false, true]
        case .zhen:
            [true, false, false]
        case .xun:
            [false, true, true]
        case .kan:
            [false, true, false]
        case .gen:
            [false, false, true]
        case .kun:
            [false, false, false]
        }
    }

    private init?(yangPattern: [Bool]) {
        guard let match = Self.allCases.first(where: { $0.yangPattern == yangPattern }) else {
            return nil
        }
        self = match
    }
}
