//
//  DeleteAccountReasons.swift
//  Bukuma_ios_swift
//
//  Created by hara on 6/20/17.
//  Copyright © 2017 Labit Inc. All rights reserved.
//

protocol DeleteAccountReasonProtocol {
    var itemTitle: String { get set }
    var itemValue: Int { get set }
    var itemDepth: Int { get set }
}

class DeleteAccountReason: DeleteAccountReasonProtocol {
    var itemTitle: String = ""
    var itemValue: Int = 0
    var itemDepth: Int = 0
    var parent: DeleteAccountReasonProtocol?

    init(withRawReason rawReason: [String: Any?], andDepth depth: Int) {
        self.itemTitle = rawReason["item_title"] as! String
        self.itemValue = rawReason["item_value"] as! Int
        self.itemDepth = depth
    }
}

class DeleteAccountReasonHaveChildren: DeleteAccountReasonProtocol {
    var itemTitle: String = ""
    var itemValue: Int = 0
    var itemDepth: Int = 0
    var isEnableChildren: Bool = false
    var childReasons: [DeleteAccountReasonProtocol] = [DeleteAccountReasonProtocol]()

    init(withRawReason rawReason: [String: Any?], andDepth depth: Int) {
        self.itemTitle = rawReason["item_title"] as! String
        self.itemValue = rawReason["item_value"] as! Int
        self.itemDepth = depth

        let childRawReasons = rawReason["child_items"] as! [[String: Any?]]
        for childRawReason in childRawReasons {
            let childReason = DeleteAccountReason(withRawReason: childRawReason, andDepth: depth + 1)
            childReason.parent = self
            self.childReasons.append(childReason)
        }
    }
}

class DeleteAccountReasons {
    var reasons: [DeleteAccountReasonProtocol] = [DeleteAccountReasonProtocol]()

    init(withRawReasons rawReasons: [[String: Any?]]) {
        for rawReason in rawReasons {
            let reason: DeleteAccountReasonProtocol = (rawReason["child_items"] != nil) ?
                DeleteAccountReasonHaveChildren(withRawReason: rawReason, andDepth: 0) :
                DeleteAccountReason(withRawReason: rawReason, andDepth: 0)
            self.reasons.append(reason)
        }
    }

    func numberOfReasons(at reasonCategory: Int) -> Int {
        let category = self.reasons[reasonCategory]
        if let haveChildren = category as? DeleteAccountReasonHaveChildren {
            if haveChildren.isEnableChildren {
                return haveChildren.childReasons.count + 1
            }
        }
        return 1
    }

    func reason(at reasonCategory: Int, with reasonDetail: Int) -> DeleteAccountReasonProtocol? {
        let category = self.reasons[reasonCategory]
        if reasonDetail == 0 {
            return category
        }

        if let haveChildren = category as? DeleteAccountReasonHaveChildren {
            if haveChildren.isEnableChildren {
                return haveChildren.childReasons[reasonDetail - 1]
            }
        }

        return nil
    }
}
