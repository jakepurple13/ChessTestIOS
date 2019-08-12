//
// Created by Jacob Rein on 2019-08-12.
// Copyright (c) 2019 Jake Rein. All rights reserved.
//

import Foundation
import UIKit

//Make this generic for swipe and tap
extension UIView {
    @discardableResult func addGesture<T: EasyGesture>(_ gestureRecognizer: T) -> T {
        let tap: EasyGesture = gestureRecognizer
        tap.addTarget(self, action: #selector(runActions(actions:)))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        return tap as! T
    }

    @discardableResult func addGesture<T: EasyGesture>(actions: @escaping (UIView, EasyGesture) -> Void) -> T {
        let tap: EasyGesture = T()
        tap.userAction = actions
        tap.addTarget(self, action: #selector(runActions(actions:)))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        return tap as! T
    }

    @discardableResult func addGesture<T: EasyGesture>(setup: @escaping (T) -> Void, actions: @escaping (UIView, EasyGesture) -> Void) -> T {
        let tap: EasyGesture = T()
        setup(tap as! T)
        tap.userAction = actions
        tap.addTarget(self, action: #selector(runActions(actions:)))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        return tap as! T
    }

    @objc internal func runActions(actions: EasyGestureAction) {
        let eg = actions as EasyGesture
        eg.userAction!(self, eg)
    }

    func removeAllGestures() {
        if let recognizers = gestureRecognizers {
            for recognizer in recognizers {
                removeGestureRecognizer(recognizer)
            }
        }
    }

    func removeGesture<T: EasyGesture>(gesture: T, customCheck: @escaping ((EasyGesture) -> Bool) = {_ in true}) {
        if let recognizers = gestureRecognizers {
            for recognizer in recognizers {
                if(recognizer is T && customCheck(recognizer as! T)) {
                    removeGestureRecognizer(recognizer)
                }
            }
        }
    }
}

protocol EasyGesture: UIGestureRecognizer {
    var userAction: ((UIView, EasyGesture) -> Void)? { get set }
}

internal class EasyGestureAction: UIGestureRecognizer, EasyGesture {
    var userAction: ((UIView, EasyGesture) -> Void)? = nil
}

public class EasyTapGesture: UITapGestureRecognizer, EasyGesture {
    var userAction: ((UIView, EasyGesture) -> Void)? = nil
}

public class EasySwipeGesture: UISwipeGestureRecognizer, EasyGesture {
    var userAction: ((UIView, EasyGesture) -> Void)? = nil
}

public class EasyLongPressGesture: UILongPressGestureRecognizer, EasyGesture {
    var userAction: ((UIView, EasyGesture) -> Void)? = nil
}

public class EasyPanGesture: UIPanGestureRecognizer, EasyGesture {
    var userAction: ((UIView, EasyGesture) -> Void)? = nil
}

public class EasyRotationGesture: UIRotationGestureRecognizer, EasyGesture {
    var userAction: ((UIView, EasyGesture) -> Void)? = nil
}

class EasyScreenEdgePanGesture: UIScreenEdgePanGestureRecognizer, EasyGesture {
    var userAction: ((UIView, EasyGesture) -> Void)? = nil
}

public class EasyPinchGesture: UIPinchGestureRecognizer, EasyGesture {
    var userAction: ((UIView, EasyGesture) -> Void)? = nil
}

public struct EasyDirection {
    public static var right: UISwipeGestureRecognizer.Direction = .right
    public static var left: UISwipeGestureRecognizer.Direction = .left
    public static var up: UISwipeGestureRecognizer.Direction = .up
    public static var down: UISwipeGestureRecognizer.Direction = .down
}