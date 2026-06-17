struct HexagramPattern: Equatable, Codable {
    let lines: [LineValue]

    init(lines: [LineValue]) {
        precondition(lines.count == 6, "A hexagram must contain exactly six lines.")
        self.lines = lines
    }

    var lowerTrigram: Trigram {
        Trigram(lines: Array(lines[0..<3]))
    }

    var upperTrigram: Trigram {
        Trigram(lines: Array(lines[3..<6]))
    }

    var movingLineNumbers: [Int] {
        lines.enumerated().compactMap { index, line in
            line.isChanging ? index + 1 : nil
        }
    }

    var changedLines: [LineValue] {
        lines.map(\.changedValue)
    }

    var changed: HexagramPattern {
        HexagramPattern(lines: changedLines)
    }

    var yangPatternKey: String {
        lines.map { $0.isYang ? "1" : "0" }.joined()
    }
}
