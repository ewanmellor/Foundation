import PMKFoundation
import Foundation
import PromiseKit
import XCTest

class NSNotificationCenterTests: XCTestCase {
    func test() {
        let PMKTestNotification = Notification.Name("PMKTestNotification")
        let ex = expectation(description: "")
        let userInfo = ["a": 1]

        let foo = NotificationCenter.default.observe(name: PMKTestNotification)

        foo.done { note in
            XCTAssertEqual(note.userInfo as? NSDictionary, userInfo as NSDictionary)
            ex.fulfill()
        }

        NotificationCenter.default.post(name: PMKTestNotification, object: nil, userInfo: userInfo)

        waitForExpectations(timeout: 1, handler: nil)
    }
}
