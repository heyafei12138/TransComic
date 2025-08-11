//
//  Trans.swift
//  comic
//
//  Created by 贺亚飞 on 2025/8/5.
//

import Foundation
import AppIntents
import UIKit
import CryptoKit
import CommonCrypto

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct Trans: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "TransIntent"

    static var title: LocalizedStringResource = "Trans"
    static var description = IntentDescription("截屏")
    let TCGroupID = "group.TranslationComic"

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
        // TODO: Place your refactored intent handler code here.
        guard let parameter = parameter else {
            throw NSError(domain: "ReturnIntent", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing parameter"])
        }
//        return .result(value: parameter)
        guard let uiImage = UIImage(data: parameter.data) else {
            throw NSError(domain: "ScreenIntent", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }
        let userDefaults = UserDefaults(suiteName: TCGroupID) ?? .standard

        let result = try  await withCheckedThrowingContinuation { continuation in
            translateImage(uiImage) { result in
                Task {
                    continuation.resume(with: result)
                }
            }
        }
        guard let renderedImage = result.renderedImage,
              let renderedData = renderedImage.pngData() else {
            throw NSError(domain: "ScreenIntent", code: 3, userInfo: [NSLocalizedDescriptionKey: "No rendered image returned"])
        }
        let processedFile = IntentFile(data: renderedData, filename: "translated_image.png", type: .png)
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        let timestamp = formatter.string(from: now)

        let saveKey = "translatedImageHistory"
        var history = userDefaults.array(forKey: saveKey) as? [[String: Any]] ?? []

        if let renderedDataString = renderedData.base64EncodedString() as String?,
           let originalDataString = parameter.data.base64EncodedString() as String? {
            let newEntry: [String: Any] = [
                "imageData": renderedDataString,
                "originalImageData": originalDataString,
                "timestamp": timestamp
            ]
            history.append(newEntry)
            userDefaults.set(history, forKey: saveKey)
        }
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("ReloadUserNumber" as CFString),
            nil,
            nil,
            true
        )

        return .result(value: processedFile)
    }
    let appKey = "529317f9e22fac7a"
    let appSecret = "yn986HzvUtvB18d92avyzR6Ua5N1ogPg"
    
    func translateImage(_ image: UIImage, from: String = "auto", to: String = "zh-CHS", completion: @escaping (Result<YoudaoTranslationResult, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "EncodeError", code: -1)))
            return
        }
        var targetCode = to
        let userDefaults = UserDefaults(suiteName: TCGroupID) ?? .standard
        if let code = userDefaults.string(forKey: "TCTargetCode"){
            targetCode = code
            print("Quick target code: \(code)")
        }
        
        let base64Image = imageData.base64EncodedString()
        let q = base64Image
        let salt = UUID().uuidString
        let curtime = String(Int(Date().timeIntervalSince1970))
        let input = truncate(q)
        let signStr = appKey + input + salt + curtime + appSecret
        let sign = shaIntent256(msg: signStr)
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "openapi.youdao.com"
        components.path = "/ocrtransapi"
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        
        let parameters: [String: String] = [
            "type": "1",
            "from": from,
            "to": targetCode,
            "appKey": appKey,
            "salt": salt,
            "sign": sign,
            "signType": "v3",
            "curtime": curtime,
            "q": q.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "",
            "render": "1",
            "docType": "json"
        ]
        
        let bodyString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(.failure(NSError(domain: "ParseError", code: -2)))
                return
            }
           
            
            if let errorCode = json["errorCode"] as? String, errorCode != "0" {
                completion(.failure(NSError(domain: "APIError", code: Int(errorCode) ?? -3)))
                return
            }
            
            var translatedTexts = [String]()
            if let resRegions = json["resRegions"] as? [[String: Any]] {
                for region in resRegions {
                    if let tranContent = region["tranContent"] as? String {
                        translatedTexts.append(tranContent)
                    }
                }
            }
            
            var renderedImage: UIImage? = nil
            if let renderInfo = json["render_image"] as? String,
               let imageData = Data(base64Encoded: renderInfo) {
                renderedImage = UIImage(data: imageData)
            }
            
            completion(.success(YoudaoTranslationResult(translatedText: translatedTexts, renderedImage: renderedImage)))
        }.resume()
    }
    func truncate(_ q: String) -> String {
        if q.count <= 20 {
            return q
        }
        let start = q.prefix(10)
        let end = q.suffix(10)
        return "\(start)\(q.count)\(end)"
    }
    struct YoudaoTranslationResult {
        let translatedText: [String]
        let renderedImage: UIImage?
    }
    func shaIntent256(msg: String) -> String {
        let data = msg.data(using: .utf8)!
        let digest = SHA256.hash(data: data)
        return digest.compactMap{String(format: "%02x", $0)}.joined()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate extension IntentDialog {
    static var parameterParameterPrompt: Self {
        "value"
    }
}

