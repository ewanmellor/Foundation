import Foundation
import PromiseKit

/**
 To import the `NSObject` category:

    use_frameworks!
    pod "PromiseKit/Foundation"

 Or `NSObject` is one of the categories imported by the umbrella pod:

    use_frameworks!
    pod "PromiseKit"
 
 And then in your sources:

    import PromiseKit
*/
extension NSObject {
    /**
      Example usage:
    
          firstly {
              myObservableObject.observe(keyPath: "myObservableValue")
          }.flatMap {
              $0[NSKeyValueChangeKey.newKey] as? MyType
          }.then { myValue in
              //…
          }.catch { error in
              do {
                  throw error
              } catch PMKError.flatMap(let any, _) {
                   //…
              }
          }

      - Returns: A promise that resolves when the provided keyPath changes.
      - Warning: *Important* The promise must not outlive the object under observation.
      - SeeAlso: Apple’s KVO documentation.
    */
    public func observe(keyPath: String) -> Guarantee<[NSKeyValueChangeKey: Any]> {
        return Guarantee {
            _ = KVOProxy(observee: self, keyPath: keyPath, resolve: $0)
        }
    }
}


private class KVOProxy: NSObject {
    var retainCycle: KVOProxy?
    let fulfill: ([NSKeyValueChangeKey: Any]) -> Void

    init(observee: NSObject, keyPath: String, resolve: @escaping ([NSKeyValueChangeKey : Any]) -> Void) {
        fulfill = resolve
        super.init()
        retainCycle = self
        pointer = Unmanaged<KVOProxy>.passUnretained(self).toOpaque()
        observee.addObserver(self, forKeyPath: keyPath, options: .new, context: pointer)
    }

    fileprivate override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == pointer else {
            return  // some third-party observer
        }
        guard let change = change else {
            return  // shouldn't happen!
        }

        fulfill(change)

        if let object = object as? NSObject, let keyPath = keyPath {
            object.removeObserver(self, forKeyPath: keyPath)
            retainCycle = nil
        }
    }

    private var pointer: UnsafeMutableRawPointer!
}
