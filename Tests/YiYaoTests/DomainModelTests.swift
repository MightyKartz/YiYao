import XCTest
@testable import YiYao

final class DomainModelTests: XCTestCase {
    func testCoinFacesUseTraditionalPointValues() {
        XCTAssertEqual(CoinFace.tails.pointValue, 2)
        XCTAssertEqual(CoinFace.heads.pointValue, 3)
    }

    func testCoinThrowsMapToLineValues() {
        XCTAssertEqual(CoinThrow(faces: [.tails, .tails, .tails]).lineValue, .oldYin)
        XCTAssertEqual(CoinThrow(faces: [.heads, .tails, .tails]).lineValue, .youngYang)
        XCTAssertEqual(CoinThrow(faces: [.heads, .heads, .tails]).lineValue, .youngYin)
        XCTAssertEqual(CoinThrow(faces: [.heads, .heads, .heads]).lineValue, .oldYang)
    }

    func testChangingLinesTransformToOppositeStableLines() {
        XCTAssertEqual(LineValue.oldYin.changedValue, .youngYang)
        XCTAssertEqual(LineValue.oldYang.changedValue, .youngYin)
        XCTAssertEqual(LineValue.youngYang.changedValue, .youngYang)
        XCTAssertEqual(LineValue.youngYin.changedValue, .youngYin)
    }

    func testTrigramsResolveFromBottomToTopLineOrder() {
        XCTAssertEqual(Trigram(lines: [.youngYang, .youngYang, .youngYang]), .qian)
        XCTAssertEqual(Trigram(lines: [.youngYin, .youngYin, .youngYin]), .kun)
        XCTAssertEqual(Trigram(lines: [.youngYang, .youngYin, .youngYang]), .li)
        XCTAssertEqual(Trigram(lines: [.youngYin, .youngYang, .youngYin]), .kan)
    }
}
