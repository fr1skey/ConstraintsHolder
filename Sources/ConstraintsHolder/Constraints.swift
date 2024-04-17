import UIKit

/// Contains all constrains references inside `storage`
public class Constraints {
    private init() { }
    /// Constraints singleton instance
    static private let main = Constraints()
    /// Constraints holders stored by <UIVIewID>
    private var storage: [UIViewID: ConstraintsHolder] = [:]
    private var hashesOfSwizzledTypes: Set<Int> = []
}

extension Constraints {
    /// Layout anchor type
    public enum ConstraintType: String {
        /// - - -
        case left, right, top, bottom, leading, trailing, centerX, centerY, width, height, baseline
        /// - - -
        ///
        ///
        ///
        /// - - -
        init?(attribute: NSLayoutConstraint.Attribute) {
            var rawValue = ""
            
            switch attribute {
            case .left:
                rawValue = Self.left.rawValue
            case .right:
                rawValue = Self.right.rawValue
            case .top:
                rawValue = Self.top.rawValue
            case .bottom:
                rawValue = Self.bottom.rawValue
            case .leading:
                rawValue = Self.leading.rawValue
            case .trailing:
                rawValue = Self.trailing.rawValue
            case .width:
                rawValue = Self.width.rawValue
            case .height:
                rawValue = Self.height.rawValue
            case .centerX:
                rawValue = Self.centerX.rawValue
            case .centerY:
                rawValue = Self.centerY.rawValue
            case .lastBaseline, .firstBaseline:
                rawValue = Self.baseline.rawValue
            default:
                ()
            }
            self.init(rawValue: rawValue)
        }
        /// - - -
    }
}


extension Constraints {
    /// Exposes  constraints container that is bound to specified view
    static func updateConstraints(_ view: UIView, exposeHolder: (ConstraintsHolder) -> Void) {
        let viewID = view.getViewID()
        
        if let constraintHolder = main.storage[viewID] {
            exposeHolder(constraintHolder)
        } else {
            let constraintHolder = ConstraintsHolder()
            main.storage[viewID] = constraintHolder
            // Swizzle methods for automatic constraints clean-up on view removing.
            // ...
            // since swizzling works on whole type and not just single instance - we need to prevent re-swizzling by knowing which types already have been swizzled
            let viewType = type(of: view)
            let viewTypeHash = ObjectIdentifier(type(of: view)).hashValue
            if main.hashesOfSwizzledTypes.contains(viewTypeHash) == false {
                swizzleDidMoveToWindow(viewType)
                main.hashesOfSwizzledTypes.insert(viewTypeHash)
            }
            // ...
            
            exposeHolder(constraintHolder)
        }
    }
    
    /// Clears up constraints container that is bound to specified view
    static func removeAllConstraints(_ view: UIView) {
        let viewID = view.getViewID()
        
        if let holder = main.storage[viewID] {
            holder.all.forEach {
                guard $0.isActive == false else {
                    let constraintType: String = holder.findTypeOfConstraint($0)?.rawValue ?? ""
                    fatalError("\(constraintType) constraint: \n \($0) must be deactivated before being removed from container.")
                }
            }
        }
        
        main.storage[viewID] = nil
    }
}


// MARK: - UIView
// Convinience methods
extension UIView {
    /// Exposes  constraints container that is bound to this view
    public func updateConstraints(exposeHolder: (Constraints.ConstraintsHolder) -> Void) {
        Constraints.updateConstraints(self) {
            exposeHolder($0)
        }
    }
    
    @available(*, deprecated, message: "Constraints now automatically cleared when view is removed from view hierarchy (window == nil)")
    public func removeFromeSuperViewAndClearConstraints() {
        self.removeAllConstraints()
        self.removeFromSuperview()
    }
    
    /// Clears up constraints container that is bound to this view
    func removeAllConstraints() {
        Constraints.removeAllConstraints(self)
    }
    
    /// Retrievs view's id
    func getViewID() -> UIViewID {
        let viewID: UIViewID
        
        if let id = self.accessibilityIdentifier {
            viewID = id
        } else {
            let id = UUID().uuidString
            self.accessibilityIdentifier = id
            viewID = id
        }
        
        return viewID
    }
}

// MARK: - Swizzling
func swizzleDidMoveToWindow<T>(_ type: T.Type) where T: UIView {
    let originalSelector = #selector(type.didMoveToWindow)
    let swizzledSelector = #selector(type.clearConstraintsRightAfterDidMoveToWindow)

    let originalMethod = class_getInstanceMethod(type, originalSelector)
    let swizzledMethod = class_getInstanceMethod(type, swizzledSelector)
    
    guard let originalMethod, let swizzledMethod else { return }
    
    let didAddMethod = class_addMethod(type, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    
    if didAddMethod {
        class_replaceMethod(type, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIView {
    /// Swizzling & clearing constraints after UIView is removed from view hierarchy
    @objc func clearConstraintsRightAfterDidMoveToWindow() {
        // call to default `didMoveToWindow()`
        self.clearConstraintsRightAfterDidMoveToWindow()
        
        // clear constraints
        if window == nil {
            self.updateConstraints { holder in
                holder.deactivateAll()
            }
            Constraints.removeAllConstraints(self)
        }
    }
}
