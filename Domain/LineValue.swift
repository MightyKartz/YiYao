enum LineValue: Int, CaseIterable, Identifiable {
    case oldYin = 6
    case youngYang = 7
    case youngYin = 8
    case oldYang = 9

    var id: Int { rawValue }

    var isYang: Bool {
        self == .youngYang || self == .oldYang
    }

    var isChanging: Bool {
        self == .oldYin || self == .oldYang
    }

    var title: String {
        switch self {
        case .oldYin:
            "老阴"
        case .youngYang:
            "少阳"
        case .youngYin:
            "少阴"
        case .oldYang:
            "老阳"
        }
    }
}
