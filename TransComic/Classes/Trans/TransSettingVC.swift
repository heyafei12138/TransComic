//
//  TransSettingVC.swift
//  TranslationAnime
//
//  Created by hebert on 2025/8/2.
//

import UIKit
import AVFoundation

class TransSettingVC: BaseViewController {
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerContainerView: UIView!
    let languageLabel = UILabel()

    private let settingBgView = UIView()
    var languageIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        reloadLanguage()
    }
    

    func setupUI() {
        title = "一键快捷翻译漫画".localized()
        setPlayerView()
        
        let desLabel = UILabel()
        desLabel.text = "设置快捷指令，轻击手机背面/单击触控实现全屏幕翻译，一次设置永久畅享。".localized()
        desLabel.font = middleFont(fontSize: 16)
        desLabel.textColor = .hexString("#999999")
        desLabel.numberOfLines = 0
        view.addSubview(desLabel)
        desLabel.textAlignment = .center
        desLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.top.equalTo(playerContainerView.snp.bottom).offset(15)
        }
        
        settingBgView.backgroundColor = .white
        settingBgView.layer.cornerRadius = 12
//        settingBgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        settingBgView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        settingBgView.layer.shadowOpacity = 1
        settingBgView.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.addSubview(settingBgView)
        settingBgView.snp.makeConstraints { make in
            make.top.equalTo(desLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(kBottomSafeHeight + 16)
        }
        
        let title = UILabel()
        title.text = "我该怎么做".localized()
        title.font = middleFont(fontSize: 12)
        title.textColor = LmainColor
        settingBgView.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview().offset(-20)
        }
        let infoBtn = UIButton(type: .custom)
        infoBtn.setImage(UIImage(named: "trans_info_icon"), for: .normal)
        infoBtn.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        settingBgView.addSubview(infoBtn)
        infoBtn.snp.makeConstraints { make in
            make.left.equalTo(title.snp.right).offset(8)
            make.centerY.equalTo(title)
            make.width.height.equalTo(16)
        }
        let line = UIView()
        line.backgroundColor = .hexString("#F1F0FF")
        settingBgView.addSubview(line)
        line.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        let title1 = UILabel()
        title1.text = "语言设置".localized()
        title1.font = middleFont(fontSize: 16)
        title1.textColor = black
        settingBgView.addSubview(title1)
        title1.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
        }
        
        let cornerView = UIView()
        cornerView.layer.cornerRadius = 8
        cornerView.layer.borderWidth = 0.5
        cornerView.layer.borderColor = LmainColor.withAlphaComponent(0.8).cgColor
        settingBgView.addSubview(cornerView)
        cornerView.snp.makeConstraints { make in
            make.top.equalTo(title1.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        let title2 = UILabel()
        title2.text = "目标语言:".localized()
        title2.font = sysfont(size: 14)
        title2.textColor = .hexString("#666666")
        cornerView.addSubview(title2)
        title2.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        languageLabel.text = "简体中文".localized()
        languageLabel.font = middleFont(fontSize: 16)
        languageLabel.textColor = mainColor
        cornerView.addSubview(languageLabel)
        languageLabel.textAlignment = .right
        languageLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(30)
            make.left.equalTo(title2.snp.right).offset(10)
        }
        let chooseimaV = UIImageView(image: UIImage(named: "arrow_down"))
        cornerView.addSubview(chooseimaV)
        chooseimaV.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(0)
            make.right.equalToSuperview().inset(14)
            make.width.height.equalTo(12)
        }
        cornerView.isUserInteractionEnabled = true
        cornerView.jk.addGestureTap { _ in
            self.chooseLanguage()
        }
        
        let startBtn = UIButton(type: .custom)
//        startBtn.setImage(UIImage(named: "image_quickTrans"), for: .normal)
        startBtn.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        settingBgView.addSubview(startBtn)
        startBtn.backgroundColor = mainColor
        startBtn.setTitle("启动快捷翻译".localized(), for: .normal)
        startBtn.setTitleColor(.white, for: .normal)
        startBtn.titleLabel?.font = BoldFont(fontSize: 24)
        startBtn.layer.cornerRadius = 16
        startBtn.layer.masksToBounds = true
//        startBtn.layer.borderWidth = 1
//        startBtn.layer.borderColor = LmainColor.withAlphaComponent(0.8).cgColor
        startBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(36)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(54)
        }
    }
    func setPlayerView() {
        guard let path = Bundle.main.path(forResource: "quick_comic_Instro", ofType: "mp4") else {
            print("找不到本地视频文件")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        queuePlayer = AVQueuePlayer()
        playerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: item)

        // 容器 view
        let width = kScreenW - (kisIphoneX ? 160 : 260)
        let height = width / 3 * 5
        let frame = CGRect(x: kisIphoneX ? 80 : 130, y: kNavHeight + 15, width: width, height: height)
        
        let container = UIView(frame: frame)
        container.backgroundColor = .black
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        view.addSubview(container)
        playerContainerView = container

        // 设置 AVPlayerLayer 到容器上
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer?.frame = container.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        if let playerLayer = playerLayer {
            container.layer.addSublayer(playerLayer)
        }

        queuePlayer?.play()
    }
    
    @objc func infoTapped() {
        let vc = TransSettinginfoVC()
        pushViewCon(vc)
    }
    func reloadLanguage() {
        languageIndex = UserDefaults.standard.integer(forKey: "SelectedLanguageCode")
        languageLabel.text = targetlanguages[languageIndex].name
    }
    
    @objc func chooseLanguage() {
        let vc = TransChooseLanguageVC()
        vc.selectedLanguageBlock = { [weak self] in
            guard let self = self else { return }
            reloadLanguage()
        }
        let segue =  SwiftMessagesBottomSegue(identifier: nil, source: self, destination: vc)

        segue.messageView.layer.shadowColor = UIColor.clear.cgColor
        segue.messageView.backgroundHeight = 435 + 16
        segue.perform()
    }
    @objc func startTapped() {
        let urlStr = "https://www.icloud.com/shortcuts/c1286d028f224e9aaa682f70aeaad62b"
        guard let url = URL(string: urlStr) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

    }

}
