import XCTest
@testable import YiYao

@MainActor
final class AppShellTests: XCTestCase {
    func testAppDefinesFivePrimaryTabsInProductOrder() {
        XCTAssertEqual(
            AppTab.allCases.map(\.title),
            ["起卦", "卦库", "记录", "学习", "设置"]
        )
    }

    func testSettingsCopyKeepsPrivacyAndDisclaimerLocalAndRestrained() {
        XCTAssertTrue(SettingsCopy.privacyBody.contains("本机"))
        XCTAssertTrue(SettingsCopy.privacyBody.contains("不上传"))
        XCTAssertTrue(SettingsCopy.disclaimerBody.contains("学习"))

        let disallowedPhrases = ["精准预测", "改命", "开运", "保证结果", "付费", "订阅", "广告", "AI"]
        for phrase in disallowedPhrases {
            XCTAssertFalse(SettingsCopy.disclaimerBody.contains(phrase), phrase)
        }
    }
}
