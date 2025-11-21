import XCTest
@testable import QuestMeSDK

final class FaceRecognitionModelWrapperTests: XCTestCase {
    func testModelInitialization() {
        let wrapper = FaceRecognitionModelWrapper()
        XCTAssertNotNil(wrapper, "モデルの初期化に失敗しました")
    }
}
