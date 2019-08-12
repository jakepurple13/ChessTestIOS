//
// Created by Jacob Rein on 2019-08-12.
// Copyright (c) 2019 Jake Rein. All rights reserved.
//

import Foundation
import UIKit

public func track(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    print("\(message) called from \(function) \(file):\(line)")
}

public enum Toast {
    case LENGTH_SHORT, LENGTH_LONG

    public var time: TimeInterval {
        switch self {
        case .LENGTH_LONG:
            return 5.0
        case .LENGTH_SHORT:
            return 2.5
        }
    }

}

extension UIViewController {
    public func showToast(message: String, duration: TimeInterval = 4.0, delay: TimeInterval = Toast.LENGTH_SHORT.time) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width / 2 - 75, y: self.view.frame.size.height - 100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = .boldSystemFont(ofSize: 16.0)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { (isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension String {
    func track() {
        Fun.track(self)
    }
}