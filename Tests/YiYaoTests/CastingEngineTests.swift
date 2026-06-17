import XCTest
@testable import YiYao

final class CastingEngineTests: XCTestCase {
    func testFixedCoinThrowsProduceOriginalChangedLinesAndMovingNumbers() {
        let coinThrows = [
            CoinThrow(faces: [.tails, .tails, .tails]),
            CoinThrow(faces: [.heads, .tails, .tails]),
            CoinThrow(faces: [.heads, .heads, .heads]),
            CoinThrow(faces: [.heads, .heads, .tails]),
            CoinThrow(faces: [.heads, .tails, .tails]),
            CoinThrow(faces: [.tails, .tails, .tails])
        ]

        let result = CastingEngine().cast(from: coinThrows)

        XCTAssertEqual(
            result.originalLines,
            [.oldYin, .youngYang, .oldYang, .youngYin, .youngYang, .oldYin]
        )
        XCTAssertEqual(
            result.changedLines,
            [.youngYang, .youngYang, .youngYin, .youngYin, .youngYang, .youngYang]
        )
        XCTAssertEqual(result.movingLineNumbers, [1, 3, 6])
        XCTAssertEqual(result.lowerTrigram, .xun)
        XCTAssertEqual(result.upperTrigram, .kan)
        XCTAssertEqual(result.changedLowerTrigram, .dui)
        XCTAssertEqual(result.changedUpperTrigram, .xun)
        XCTAssertEqual(result.coinThrows, coinThrows)
    }

    func testUnchangingHexagramKeepsChangedLinesTheSame() {
        let coinThrows = [
            CoinThrow(faces: [.heads, .tails, .tails]),
            CoinThrow(faces: [.heads, .heads, .tails]),
            CoinThrow(faces: [.heads, .tails, .tails]),
            CoinThrow(faces: [.heads, .heads, .tails]),
            CoinThrow(faces: [.heads, .tails, .tails]),
            CoinThrow(faces: [.heads, .heads, .tails])
        ]

        let result = CastingEngine().cast(from: coinThrows)

        XCTAssertEqual(result.movingLineNumbers, [])
        XCTAssertEqual(result.changedLines, result.originalLines)
    }

    func testInjectedThrowProviderIsUsedSixTimesFromBottomToTop() {
        let coinThrows = [
            CoinThrow(faces: [.heads, .tails, .tails]),
            CoinThrow(faces: [.heads, .heads, .tails]),
            CoinThrow(faces: [.tails, .tails, .tails]),
            CoinThrow(faces: [.heads, .heads, .heads]),
            CoinThrow(faces: [.heads, .tails, .tails]),
            CoinThrow(faces: [.heads, .heads, .tails])
        ]
        var index = 0
        let engine = CastingEngine {
            defer { index += 1 }
            return coinThrows[index]
        }

        let result = engine.cast()

        XCTAssertEqual(index, 6)
        XCTAssertEqual(result.coinThrows, coinThrows)
        XCTAssertEqual(result.originalLines, [.youngYang, .youngYin, .oldYin, .oldYang, .youngYang, .youngYin])
    }

    func testRandomEngineAlwaysReturnsSixValidLines() {
        let engine = CastingEngine()

        for _ in 0..<20 {
            let result = engine.cast()

            XCTAssertEqual(result.coinThrows.count, 6)
            XCTAssertEqual(result.originalLines.count, 6)
            XCTAssertTrue(result.originalLines.allSatisfy { LineValue.allCases.contains($0) })
        }
    }
}
