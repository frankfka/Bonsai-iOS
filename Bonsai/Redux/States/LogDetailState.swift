//
// Created by Frank Jia on 2019-12-22.
// Copyright (c) 2019 Frank Jia. All rights reserved.
//

import Foundation

struct LogDetailState {
    var loggable: Loggable? = nil
    var isLoading: Bool = false
    var loadError: Error? = nil
    var isDeleting: Bool = false
    var deleteSuccess: Bool = false
    var deleteError: Error? = nil
    // Analytics
    var symptomSeverityAnalytics: SymptomSeverityAnalytics? = nil
    var isLoadingAnalytics: Bool = false
    var loadAnalyticsError: Error? = nil
}
