//
//  TrackerStoreError.swift
//  Tracker
//
//  Created by Maksim Zimens on 28.01.2024.
//

import Foundation

enum StoreErrors {
    enum TrackrerCategoryStoreError: Error {
        case decodingErrorInvalidNameCategory
        case getCategoryCoreDataError
        
        var localizedDescription: String {
            var localizedDescription = ""
            switch self {
            case .decodingErrorInvalidNameCategory:
                localizedDescription = Translate.decodingErrorInvalidNameCategory
            case .getCategoryCoreDataError:
                localizedDescription = Translate.getCategoryCoreDataError
            }
            return localizedDescription
        }
    }
    
    enum TrackrerStoreError: Error {
        case getTrackerError
        case decodingErrorInvalidName
        case decodingErrorInvalidId
        case decodingErrorInvalidColor
        case decodingErrorInvalidEmoji
        case decodingErrorInvalidSchedul
        
        var localizedDescription: String {
            var localizedDescription = ""
            switch self {
            case .getTrackerError:
                localizedDescription = Translate.getTrackerError
            case .decodingErrorInvalidName:
                localizedDescription = Translate.decodingErrorInvalidName
            case .decodingErrorInvalidId:
                localizedDescription = Translate.decodingErrorInvalidId
            case .decodingErrorInvalidColor:
                localizedDescription = Translate.decodingErrorInvalidColor
            case .decodingErrorInvalidEmoji:
                localizedDescription = Translate.decodingErrorInvalidEmoji
            case .decodingErrorInvalidSchedul:
                localizedDescription = Translate.decodingErrorInvalidSchedul
            }
            
            return localizedDescription
        }
    }
    
    enum NSSetError: Error {
        case transformationErrorInvalid
        
        var localizedDescription: String {
            Translate.transformationErrorInvalid
        }
    }
    
    enum TrackrerRecordStoreError: String, Error {
        case decodingErrorInvalidId
        case decodingErrorInvalidDate
        case loadTrackerRecord
        case getTrackerRecord
        
        var localizedDescription: String {
            var localizedDescription = ""
            switch self {
            case .decodingErrorInvalidId:
                localizedDescription = Translate.decodingErrorInvalidId
            case .decodingErrorInvalidDate:
                localizedDescription = Translate.decodingErrorInvalidDate
            case .loadTrackerRecord:
                localizedDescription = Translate.loadTrackerRecord
            case .getTrackerRecord:
                localizedDescription = Translate.getTrackerRecord
            }
            
            return localizedDescription
        }
    }
}
