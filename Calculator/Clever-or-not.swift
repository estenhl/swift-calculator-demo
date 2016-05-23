import Foundation

var AssociatedObjectHandleForTerseDateFormatter: UInt8 = 0

public extension NSDate {
    
    static var terseDateFormatter: NSDateFormatter {
        get {
            if let df = objc_getAssociatedObject(self, &AssociatedObjectHandleForTerseDateFormatter) as? NSDateFormatter {
                return df
            } else {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                dateFormatter.timeZone = NSTimeZone.localTimeZone()
                dateFormatter.locale = NSLocale.currentLocale()
                objc_setAssociatedObject(self, &AssociatedObjectHandleForTerseDateFormatter, dateFormatter, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return dateFormatter
            }
        }
    }
}

