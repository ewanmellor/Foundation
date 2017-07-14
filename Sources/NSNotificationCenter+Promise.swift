import Foundation.NSNotification
import PromiseKit

/**
 To import the `NSNotificationCenter` category:

    use_frameworks!
    pod "PromiseKit/Foundation"

 Or `NSNotificationCenter` is one of the categories imported by the umbrella pod:

    use_frameworks!
    pod "PromiseKit"

 And then in your sources:

    import PromiseKit
*/
extension NotificationCenter {
    /// Observe the named notification once
    public func observe(name: Notification.Name, object: Any? = nil) -> Guarantee<Notification> {
        let (guarantee, fulfill) = Guarantee<Notification>.pending()
        let id = addObserver(forName: name, object: object, queue: nil, using: fulfill)
        return guarantee.done { _ in
            self.removeObserver(id)
        }
    }
}
