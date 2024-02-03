import Foundation
import YandexMobileMetrica

protocol AnalyticsServiceProtocol {
    static func reportEvent(field: MetricEvent)
}

struct AnalyticsService: AnalyticsServiceProtocol {
    static func reportEvent(field: MetricEvent) {
        YMMYandexMetrica.reportEvent(field.event.rawValue,
                                     parameters: field.params,
                                     onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}

