//
//  Models.swift
//  KaizenOS
//
//  Created by Avneet Singh on 5/21/24.
//

import Foundation


enum VoiceType: String, Codable, Hashable, Sendable, CaseIterable {
    case alloy
    case echo
    case fable
    case onyx
    // case nova
    // case shimmer
}

enum VoiceChatState {
    case idle
    case recordingSpeech
    case processingSpeech
    case playingSpeech
    case error(Error)
}


