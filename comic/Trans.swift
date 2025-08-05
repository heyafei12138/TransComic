//
//  Trans.swift
//  comic
//
//  Created by 贺亚飞 on 2025/8/5.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct Trans: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "TransIntent"

    static var title: LocalizedStringResource = "Trans"
    static var description = IntentDescription("截屏")

    @Parameter(title: "Parameter")
    var parameter: IntentFile?

    static var parameterSummary: some ParameterSummary {
        Summary("value") {
            \.$parameter
        }
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$parameter)) { parameter in
            DisplayRepresentation(
                title: "value",
                subtitle: ""
            )
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
        guard let parameter = parameter else {
            throw NSError(domain: "ReturnIntent", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing parameter"])
        }

        return .result(value: parameter)
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate extension IntentDialog {
    static var parameterParameterPrompt: Self {
        "value"
    }
}

