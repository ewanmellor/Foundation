import PMKFoundation
import Foundation
import PromiseKit
import XCTest

class NSObjectTests: XCTestCase {
    func testKVO() {
        let ex = expectation(description: "")
        let foo = Foo()

        foo.observe(keyPath: "bar").flatMap {
            $0[.newKey] as? String
        }.done {
            XCTAssertEqual($0, "moo")
            ex.fulfill()
        }.catch {
            XCTFail("\($0)")
        }

        foo.bar = "moo"

        waitForExpectations(timeout: 1)
    }

    func testAfterlife() {
        let ex = expectation(description: "")
        var killme: NSObject!

        autoreleasepool {

            func innerScope() {
                killme = NSObject()
                after(life: killme).done(execute: ex.fulfill)
            }

            innerScope()

            after(.milliseconds(200)).done {
                killme = nil
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testMultiObserveAfterlife() {
        let ex1 = expectation(description: "")
        let ex2 = expectation(description: "")
        var killme: NSObject!

        autoreleasepool {

            func innerScope() {
                killme = NSObject()
                after(life: killme).done(execute: ex1.fulfill)
                after(life: killme).done(execute: ex2.fulfill)
            }

            innerScope()

            after(.milliseconds(200)).done {
                killme = nil
            }
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}

private class Foo: NSObject {
    dynamic var bar: String = "bar"
}
