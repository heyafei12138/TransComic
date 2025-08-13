//
//  TCImageLoadingVC.swift
//  TransComic
//
//  Created by hebert on 2025/8/8.
//

import UIKit
import Lottie
import CommonCrypto

class TCImageLoadingVC: UIViewController {

    private let topGifImageView = LottieAnimationView(name: "lottie_image")
    private let topTitleLabel = UILabel()
    private let bottomTitleLabel = UILabel()
    private let closeButton = UIButton(type: .custom)
    var images: [UIImage] = []
    var transResults: (([UIImage]) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        transImage()
    }
    func transImage(){
        let Helper = ImageTranslator()

        Helper.batchTranslateNew(images: images) { images in
            let validImages = images.compactMap { $0 } // 过滤掉 nil
            self.transResults?(validImages)
            self.view.removeFromSuperview()
        }
        
        
    }

    private func setupUI() {
        view.backgroundColor = .black.withAlphaComponent(0.2)
        
        // Top GIF
        view.addSubview(topGifImageView)
        topGifImageView.contentMode = .scaleAspectFit
        topGifImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(240)
        }
        topGifImageView.animationSpeed = 1
        topGifImageView.play()
        
        topGifImageView.loopMode = .loop
        //        if let bundleURL = Bundle.main
//            .url(forResource: "icon_transimage_loding", withExtension: "gif"){
//            if let imageData = try? Data(contentsOf: bundleURL),let source = CGImageSourceCreateWithData(imageData as CFData, nil) {
//                if let images = UIImage().getSourcesImages(source) {
//                    self.images = images
//                    topGifImageView.image = UIImage.animatedImage(with: images, duration: 0.8)
//                }
//            }
//        }

        // Top Title
        view.addSubview(topTitleLabel)
        topTitleLabel.font = .systemFont(ofSize: 16, weight: UIFont.Weight(rawValue: 0.43))
        topTitleLabel.textColor = .black
        topTitleLabel.textAlignment = .center
        topTitleLabel.numberOfLines = 1
        topTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(topGifImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(20)
            make.right.lessThanOrEqualToSuperview().offset(-20)
        }
        
        // Bottom GIF
//        view.addSubview(bottomGifImageView)
//        bottomGifImageView.contentMode = .scaleAspectFit
//        bottomGifImageView.snp.makeConstraints { make in
//            make.top.equalTo(topTitleLabel.snp.bottom).offset(7)
//            make.centerX.equalToSuperview()
//            make.size.equalTo(CGSizeMake(191, 16))
//        }
//        bottomGifImageView.play()
//        bottomGifImageView.loopMode = .loop
//        bottomGifImageView.animationSpeed = 1
        // Bottom Title
        view.addSubview(bottomTitleLabel)
        bottomTitleLabel.font = sysfont(size: 12)
        bottomTitleLabel.textColor = .black
        bottomTitleLabel.textAlignment = .center
        bottomTitleLabel.numberOfLines = 0
        bottomTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(topTitleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(20)
            make.right.lessThanOrEqualToSuperview().offset(-20)
        }
        
        // Close Button
        view.addSubview(closeButton)
        
        
//        closeButton.layer.cornerRadius = 22
        closeButton.setImage(UIImage(named: "close_icon"), for: .normal)
        closeButton.clipsToBounds = true
        closeButton.setTitleColor(LmainColor.withAlphaComponent(0.2), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.snp.makeConstraints { make in
            make.bottom.equalTo(topGifImageView.snp.top).offset(30)
            make.left.equalTo(topGifImageView.snp.right).offset(-10)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        topTitleLabel.text = "loading...".localized()
        bottomTitleLabel.text = "翻译中，请等待...".localized()
        
        
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.snp.makeConstraints { make in
            make.top.equalTo(topGifImageView.snp.top).offset(-0)
            make.left.equalTo(topGifImageView.snp.left).offset(-20)
            make.right.equalTo(topGifImageView.snp.right).offset(20)
            make.bottom.equalTo(bottomTitleLabel.snp.bottom).offset(30)
        }
        view.sendSubviewToBack(contentView)
    }
    
    @objc private func closeButtonTapped() {
       
//        self.dismiss(animated: false, completion: nil)
        self.view.removeFromSuperview()
       
    }
    
    
}


import CryptoKit

class ImageTranslator {
    
  
    /// 批量图片翻译，限速每秒5张
    func batchTranslateNew(images: [UIImage], to: String = "zh-CHS", completion: @escaping ([UIImage?]) -> Void) {
        let index = UserDefaults.standard.integer(forKey: "SelectedLanguageCode")
        let toLanguage = targetlanguages[index].code
        var results: [UIImage?] = Array(repeating: nil, count: images.count)
        let queue = DispatchQueue(label: "translate.serial")
        let interval: TimeInterval = 1.0 / 3.0
        var imageIndex = 0

        func processNext() {
            guard imageIndex < images.count else {
                DispatchQueue.main.async {
                    completion(results)
                }
                return
            }

            let currentIndex = imageIndex
            let image = images[currentIndex]
            let translator = TAYoudaoImageTranslator()

            translator.translateImage(image, to: toLanguage) { result in
                switch result {
                case .success(let output):
                    results[currentIndex] = output.renderedImage
                case .failure(let error):
                    results[currentIndex] = UIImage(named: "image_picture_norecords_1")
                    print("翻译失败（第 \(currentIndex) 张）：\(error.localizedDescription)")
                   
                }

                imageIndex += 1

                // 节流等待 interval 秒再处理下一张
                queue.asyncAfter(deadline: .now() + interval) {
                    processNext()
                }
            }
        }

        queue.async {
            processNext()
        }
    }


    
    
    private func imageToBase64String(_ image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        return imageData.base64EncodedString()
    }
}

// MARK: - UIImage绘制文字扩展
private extension UIImage {
    
    func drawTranslatedLabels(from values: [[String: Any]]) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        self.draw(at: .zero)
        
        for item in values {
            guard let x = item["X"] as? CGFloat,
                  let y = item["Y"] as? CGFloat,
                  let w = item["W"] as? CGFloat,
                  let h = item["H"] as? CGFloat,
                  let text = item["TargetText"] as? String else {
                continue
            }
          let scaleFactor = 1.0
            let rect = CGRect(x: x / scaleFactor, y: y / scaleFactor, width: w / scaleFactor, height: h / scaleFactor)
//            let rect = CGRect(x:  x / 2 , y: y / 2, width: w / 2, height: h / 2)
            let cornerRadius = min(rect.width, rect.height) * 0.1
                let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            context.setFillColor(UIColor.lightGray.cgColor)
                context.addPath(path.cgPath)
                context.fillPath()
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: h / scaleFactor),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            attributedString.draw(in: rect)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

struct YoudaoTranslationResult {
    let translatedText: [String]
    let renderedImage: UIImage?
}

class TAYoudaoImageTranslator {
    
    let appKey = "529317f9e22fac7a"
    let appSecret = "yn986HzvUtvB18d92avyzR6Ua5N1ogPg"
    
    func translateImage(_ image: UIImage, from: String = "auto", to: String = "zh-CHS", completion: @escaping (Result<YoudaoTranslationResult, Error>) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "EncodeError", code: -1)))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        let q = base64Image
        let salt = UUID().uuidString
        let curtime = String(Int(Date().timeIntervalSince1970))
        let input = self.truncate(q)
        let signStr = appKey + input + salt + curtime + appSecret
        let sign = signStr.sha256()
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "openapi.youdao.com"
        components.path = "/ocrtransapi"
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        
        let parameters: [String: String] = [
            "type": "1",
            "from": from,
            "to": to,
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
            
            // 获取渲染图片 base64 字符串
            var renderedImage: UIImage? = nil
            if let renderInfo = json["render_image"] as? String,
               let imageData = Data(base64Encoded: renderInfo) {
                renderedImage = UIImage(data: imageData)
            }
            
            completion(.success(YoudaoTranslationResult(translatedText: translatedTexts, renderedImage: renderedImage)))
        }.resume()
    }
    
    private func truncate(_ q: String) -> String {
        if q.count <= 20 {
            return q
        }
        let start = q.prefix(10)
        let end = q.suffix(10)
        return "\(start)\(q.count)\(end)"
    }
}

// MARK: - SHA256

extension String {
    func sha256() -> String {
        guard let data = self.data(using: .utf8) else { return "" }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
