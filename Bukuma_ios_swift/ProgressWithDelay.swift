//
//  ProgressWithDelay.swift
//  Bukuma_ios_swift
//
//  Created by hara on 5/31/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

import SVProgressHUD

protocol ProgressWithDelayProtocol {
    var delayTimer: Timer? { get set }
    var timeoutTimer: Timer? { get set }

    func installProgress(withDelay delay: TimeInterval)
    func removeProgress()

    func delayedProgress(_ sender: Timer)
    func timeoutProgress(_ sender: Timer)
}

class ProgressWithDelay: ProgressWithDelayProtocol {
    internal var delayTimer: Timer?
    internal var timeoutTimer: Timer?

    func installProgress(withDelay delay: TimeInterval) {
        self.delayTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(self.delayedProgress(_:)), userInfo: nil, repeats: false)
    }

    func removeProgress() {
        if let delayTimer = self.delayTimer {
            delayTimer.invalidate()
            self.delayTimer = nil
        } else {
            SVProgressHUD.dismiss()

            self.timeoutTimer?.invalidate()
            self.timeoutTimer = nil
        }
    }

    @objc func delayedProgress(_ sender: Timer) {
        self.delayTimer?.invalidate()
        self.delayTimer = nil

        SVProgressHUD.show()

        self.timeoutTimer = Timer.scheduledTimer(timeInterval: self.progressTimeout, target: self, selector: #selector(self.timeoutProgress(_:)), userInfo: nil, repeats: false)
    }

    private let progressTimeout: TimeInterval = 20

    @objc func timeoutProgress(_ sender: Timer) {
        SVProgressHUD.dismiss()

        self.timeoutTimer?.invalidate()
        self.timeoutTimer = nil
    }
}
