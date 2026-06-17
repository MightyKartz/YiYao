struct CastingResult: Equatable, Codable {
    let coinThrows: [CoinThrow]
    let originalPattern: HexagramPattern
    let changedPattern: HexagramPattern

    init(coinThrows: [CoinThrow]) {
        precondition(coinThrows.count == 6, "A casting result must contain exactly six coin throws.")
        self.coinThrows = coinThrows
        self.originalPattern = HexagramPattern(lines: coinThrows.map(\.lineValue))
        self.changedPattern = originalPattern.changed
    }

    var originalLines: [LineValue] {
        originalPattern.lines
    }

    var changedLines: [LineValue] {
        changedPattern.lines
    }

    var movingLineNumbers: [Int] {
        originalPattern.movingLineNumbers
    }

    var lowerTrigram: Trigram {
        originalPattern.lowerTrigram
    }

    var upperTrigram: Trigram {
        originalPattern.upperTrigram
    }

    var changedLowerTrigram: Trigram {
        changedPattern.lowerTrigram
    }

    var changedUpperTrigram: Trigram {
        changedPattern.upperTrigram
    }
}
