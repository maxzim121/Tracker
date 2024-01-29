//
//  TrackerStoreError.swift
//  Tracker
//
//  Created by Maksim Zimens on 28.01.2024.
//

import Foundation

enum TrackrerStoreError: Error {
    case decodingErrorInvalidName
    case decodingErrorInvalidId
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidSchedul
}
