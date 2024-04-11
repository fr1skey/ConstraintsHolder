import UIKit

extension Constraints {
    /// Container assigned to view with all constraints that has been added to it
    public class ConstraintsHolder {
        /// constraint values with a constraint-type as a key
        private var constraints: [ConstraintType: NSLayoutConstraint?] = [:]
        
        /// - - -
        public var left: NSLayoutConstraint? {
            get {
                constraints[.left] ?? nil
            }
            set {
                // type of constraint that is valid for this variable
                let constraintVariableType: ConstraintType = .left
                
                verifyConstraintAndAssignIt(newValue, constraintVariableType)
            }
        }
        
        public var right: NSLayoutConstraint? {
            get {
                constraints[.right] ?? nil
            }
            set {
                // type of constraint that is valid for this variable
                let constraintVariableType: ConstraintType = .right
                
                verifyConstraintAndAssignIt(newValue, constraintVariableType)
            }
        }
        
        public var top: NSLayoutConstraint? {
            get {
                constraints[.top] ?? nil
            }
            set {
                // type of constraint that is valid for this variable
                let constraintVariableType: ConstraintType = .top
                
                verifyConstraintAndAssignIt(newValue, constraintVariableType)
            }
        }
        
        public var bottom: NSLayoutConstraint? {
            get {
                constraints[.bottom] ?? nil
            }
            set {
                // type of constraint that is valid for this variable
                let constraintVariableType: ConstraintType = .bottom
                
                verifyConstraintAndAssignIt(newValue, constraintVariableType)
            }
        }
        
        public var leading: NSLayoutConstraint? {
            get {
                constraints[.leading] ?? nil
            }
            set {
                // type of constraint that is valid for this variable
                let constraintVariableType: ConstraintType = .leading
                
                verifyConstraintAndAssignIt(newValue, constraintVariableType)
            }
        }
        
        public var trailing: NSLayoutConstraint? {
            get {
                constraints[.trailing] ?? nil
            }
            set {
                // type of constraint that is valid for this variable
                let constraintVariableType: ConstraintType = .trailing
                
                verifyConstraintAndAssignIt(newValue, constraintVariableType)
            }
        }
        
        public var centerX: NSLayoutConstraint? {
            get {
                constraints[.centerX] ?? nil
            }
            set {
                // type of constraint that is valid for this variable
                let constraintVariableType: ConstraintType = .centerX
                
                verifyConstraintAndAssignIt(newValue, constraintVariableType)
            }
        }
        
        public var centerY: NSLayoutConstraint? {
            get {
                constraints[.centerY] ?? nil
            }
            set {
                // type of constraint that is valid for this variable
                let constraintVariableType: ConstraintType = .centerY
                
                verifyConstraintAndAssignIt(newValue, constraintVariableType)
            }
        }
        
        public var baseline: NSLayoutConstraint? {
            get {
                constraints[.baseline] ?? nil
            }
            set {
                // type of constraint that is valid for this variable
                let constraintVariableType: ConstraintType = .baseline
                
                verifyConstraintAndAssignIt(newValue, constraintVariableType)
            }
        }
        
        public var width: NSLayoutConstraint? {
            get {
                constraints[.width] ?? nil
            }
            set {
                // type of constraint that is valid for this variable
                let constraintVariableType: ConstraintType = .width
                
                verifyConstraintAndAssignIt(newValue, constraintVariableType)
            }
        }
        
        public var height: NSLayoutConstraint? {
            get {
                constraints[.height] ?? nil
            }
            set {
                // type of constraint that is valid for this variable
                let constraintVariableType: ConstraintType = .height
                
                verifyConstraintAndAssignIt(newValue, constraintVariableType)
            }
        }
        /// - - -
        ///
        ///
        ///
        /// - - -
        /// Returns all constraints contained in this holder
        public var all: [NSLayoutConstraint] {
            constraints.values.compactMap { $0 }
        }
        
        /// Returns active constraints contained in this holder
        public func activeConstraints() -> [Constraints.ConstraintType: NSLayoutConstraint] {
            var activeConstraints: [Constraints.ConstraintType: NSLayoutConstraint] = [:]
            
            constraints.forEach { key, value in
                if value?.isActive == true {
                    activeConstraints[key] = value
                }
            }
            
            return activeConstraints
        }
        /// - - -
        ///
        ///
        ///
        /// - - -
        /// Activate specified constraints stored in holder
        @MainActor public func activate(_ keyPaths: [KeyPath<Constraints.ConstraintsHolder, NSLayoutConstraint?>]) {
            let constraints = keyPaths.map { self[keyPath: $0] }
            
            let unwrappedConstraints = constraints.compactMap { $0 }
            
            guard unwrappedConstraints.count == keyPaths.count else {
                fatalError("keyPath passed to activate() contained nil value constraint")
            }
            
            NSLayoutConstraint.activate(unwrappedConstraints)
        }
        /// Deactivate specified constraints stored in holder
        @MainActor public func deactivate(_ keyPaths: [KeyPath<Constraints.ConstraintsHolder, NSLayoutConstraint?>]) {
            let constraints = keyPaths.map { self[keyPath: $0] }
            
            let unwrappedConstraints = constraints.compactMap { $0 }
            
            guard unwrappedConstraints.count == constraints.count else {
                fatalError("constraints passed to deactivate() contained nil value")
            }
            
            NSLayoutConstraint.deactivate(unwrappedConstraints)
        }
        /// - - -
        ///
        ///
        ///
        /// - - -
        func findTypeOfConstraint(_ constraint: NSLayoutConstraint) -> ConstraintType? {
            constraints.first(where: { $0.value == constraint })?.key
        }
        /// - - -
        ///
        ///
        ///
        /// - - -
        /// Perfom various checks before assigning newValue to `constraints`
        private func verifyConstraintAndAssignIt(_ constraint: NSLayoutConstraint?, _ constraintVariableType: ConstraintType) {
            // check that constraint is deactivated before removing from `constraints`
            if constraint == nil && constraints[constraintVariableType]??.isActive == true {
                fatalError("\(constraintVariableType) constraint must be deactivated first")
            }
            
            // check that constraint is of valid type
            if let constraint, let constraintType = ConstraintType(attribute: constraint.firstAttribute), constraintType != constraintVariableType {
                fatalError("Can't assign value of \(ConstraintType.self) \(constraintType) to variable of \(ConstraintType.self) \(constraintVariableType)")
            }
            
            // assign new value
            constraints[constraintVariableType] = constraint
        }
        /// - - -
    }
}
