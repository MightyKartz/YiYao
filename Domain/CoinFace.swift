enum CoinFace: Int, CaseIterable, Identifiable, Codable {
    case tails = 2
    case heads = 3

    var id: Int { rawValue }

    var pointValue: Int {
        rawValue
    }

    var title: String {
        switch self {
        case .heads:
            "正"
        case .tails:
            "背"
        }
    }

    static func random() -> CoinFace {
        Bool.random() ? .heads : .tails
    }
}
