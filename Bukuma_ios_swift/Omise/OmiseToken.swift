//
//  Token.swift
//  Omise-iOS_SDK
//
//  Created by Anak Mirasing on 6/13/2558 BE.
//  Copyright (c) 2558 omise. All rights reserved.
//

import Foundation

@objc(OMSToken) public class OmiseToken: NSObject {
    /// Token's ID.
    @objc public var tokenId: String?
    /// Boolean flag indicating wether this card is a live card or a test card.
    @objc public var livemode: Bool = false
    /// Resource URL that can be used to re-load token information.
    @objc public var location: String?
    /// Boolean flag indicating whether the token has been used or not.
    /// Tokens can only be used once to make create a Charge or to create a saved Card record.
    @objc public var used: Bool = false
    /// Card information used to generate this token.
    @objc public var card: OmiseCard?
    /// Token's creation time.
    @objc public var created: Date?
}
