import PMKFoundation
import OHHTTPStubs
import PromiseKit
import XCTest

class NSURLSessionTests: XCTestCase {
    func test1() {
        let json: NSDictionary = ["key1": "value1", "key2": ["value2A", "value2B"]]

        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }

        let ex = expectation(description: "")
        let rq = URLRequest(url: URL(string: "http://example.com")!)
        firstly {
            URLSession.shared.dataTask(.promise, with: rq)
        }.flatMap { data, _ in
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        }.done { rsp in
            XCTAssertEqual(json, rsp as NSDictionary)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func test2() {

        // test that URLDataPromise chains thens
        // this test because I don’t trust the Swift compiler

        let dummy = ("fred" as NSString).data(using: String.Encoding.utf8.rawValue)!

        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(data: dummy, statusCode: 200, headers: [:])
        }

        let ex = expectation(description: "")
        let rq = URLRequest(url: URL(string: "http://example.com")!)

        after(.milliseconds(100)).then {
            URLSession.shared.dataTask(.promise, with: rq)
        }.done { x, _ in
            XCTAssertEqual(x, dummy)
            ex.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }
}
