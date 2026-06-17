struct CoinThrow: Equatable, Codable {
    let faces: [CoinFace]

    init(faces: [CoinFace]) {
        precondition(faces.count == 3, "A coin throw must contain exactly three coin faces.")
        self.faces = faces
    }

    var total: Int {
        faces.reduce(0) { partialResult, face in
            partialResult + face.pointValue
        }
    }

    var lineValue: LineValue {
        guard let value = LineValue(coinTotal: total) else {
            preconditionFailure("Three coin faces must produce a line value from 6 through 9.")
        }
        return value
    }

    static func random() -> CoinThrow {
        CoinThrow(faces: (0..<3).map { _ in CoinFace.random() })
    }
}
