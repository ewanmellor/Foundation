import PMKFoundation
import Foundation
import PromiseKit
import XCTest

#if os(macOS)

class NSTaskTests: XCTestCase {
    func test1() {
        let ex = expectation(description: "")
        let task = Process()
        task.launchPath = "/usr/bin/basename"
        task.arguments = ["/foo/doe/bar"]
        task.launch(.promise).done { stdout, _ -> Void in
            let txt = String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
            XCTAssertEqual(txt, "bar\n")
            ex.fulfill()
        }
        waitForExpectations(timeout: 10)
    }

    func test2() {
        let ex = expectation(description: "")
        let dir = "PMKAbsentDirectory"

        let task = Process()
        task.launchPath = "/bin/ls"
        task.arguments = [dir]

        task.launch(.promise).done { _ in
            XCTFail()
        }.catch { err in
            if case Process.PMKError.execution(let proc) = err {
                let expectedStderrData = "ls: \(dir): No such file or directory\n".data(using: .utf8, allowLossyConversion: false)!

                XCTAssertEqual((proc.standardError as? Pipe)?.fileHandleForReading.readDataToEndOfFile(), expectedStderrData)
                XCTAssertEqual(proc.terminationStatus, 1)
                XCTAssertEqual((proc.standardOutput as? Pipe)?.fileHandleForReading.readDataToEndOfFile().count, 0)
                ex.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }
    
    func test3() {
        // NSTask throws an ObjC exceptionn if the launchPath is not
        // executable! So we pre-emptively check for that in our Swift
        // code and throw a Swift error instead.
        
        let ex = expectation(description: "")

        let task = Process()
        task.launchPath = "/bin/non-existent-file"
        task.launch(.promise).catch { error in
            if case Process.PMKError.notExecutable(let path) = error {
                XCTAssertEqual(path, task.launchPath)
            } else {
                XCTFail()
            }
            ex.fulfill()
        }
        
        waitForExpectations(timeout: 10)        
    }
}

#endif
