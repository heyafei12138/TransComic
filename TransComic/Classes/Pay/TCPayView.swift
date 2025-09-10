//
//  TCPayView.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/9/10.
//

import Foundation


final class TCPriceChooseView: UIView {
    
    struct ItemStaticConfig {
        enum Style { case plainCard, ribbonCard,thrCard }   // 第1项 plain，第2/3项 ribbon
        let style: Style
        let mainTitle: String       // 卡片内「标题」
        let note: String            // 卡片内「小字注释」
        // 提示：第2/3项顶部横条标题固定为“最多人选”，不开放自定义
        let ribbonIcon: UIImage?    // 仅 ribbonCard 生效；nil 用默认
    }
    
    // 对外属性
    var onSelectionChanged: ((Int) -> Void)?
    private(set) var selectedIndex: Int = 0
    
    // 颜色与外观
    var accentColor: UIColor = .black
    var cardBorderColor: UIColor = mainColor
    var ribbonBaseColor: UIColor = .hexString("#F2F2F2")
    var ribbonSelectedBaseColor: UIColor = LmainColor
    var cardCornerRadius: CGFloat = 12
    var cardBorderWidth: CGFloat = 1
    
    // 内部视图
    private var itemViews: [OptionItemView] = []
    
    // MARK: - Init
    /// 传入三项的固定标题与注释；第2/3项自动带“最多人选”横条。
    convenience init(
        
    ) {
        let cfgs: [ItemStaticConfig] = [
            .init(style: .plainCard,  mainTitle: "1个月".localized(), note: "￥", ribbonIcon: nil),
            .init(style: .thrCard, mainTitle: "3个月".localized(), note: "￥", ribbonIcon: UIImage(named: "choose908")),
            .init(style: .ribbonCard, mainTitle: "12个月".localized(), note: "￥", ribbonIcon: UIImage(named: "choose908"))
        ]
        self.init(configs: cfgs)
    }
    
    init(configs: [ItemStaticConfig]) {
        assert(configs.count == 3, "需要正好三项")
        super.init(frame: .zero)
        buildUI(configs: configs)
        setSelected(index: 0, notify: false)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Public API
    /// 仅允许外部修改描述
    func updateDescription(at index: Int, text: String?) {
        guard index >= 0 && index < itemViews.count else { return }
        itemViews[index].setDescription(text,type: index)
    }
    
    func setSelected(index: Int, notify: Bool = true) {
        guard index >= 0 && index < itemViews.count else { return }
        selectedIndex = index
        for (i, v) in itemViews.enumerated() {
            v.applySelected(i == index,
                            accent: accentColor,
                            cardBorderDefault: cardBorderColor,
                            ribbonBase: ribbonBaseColor,
                            ribbonSelectedBase: ribbonSelectedBaseColor)
        }
        if notify {
            onSelectionChanged?(index)
        }
    }
    
    // MARK: - Build UI
    private func buildUI(configs: [ItemStaticConfig]) {
        backgroundColor = .clear
        
        for (idx, cfg) in configs.enumerated() {
            let v = OptionItemView(index: idx,
                                   style: cfg.style,
                                   mainTitle: cfg.mainTitle,
                                   note: cfg.note,
                                   cardCornerRadius: cardCornerRadius,
                                   cardBorderWidth: cardBorderWidth,
                                   cardBorderColor: cardBorderColor,
                                   ribbonIcon: cfg.ribbonIcon)
            addSubview(v)
            itemViews.append(v)
            
            v.onTap = { [weak self] i in self?.setSelected(index: i) }
        }
        
        // 等宽横向布局
        itemViews[0].snp.makeConstraints { make in
            make.bottom.left.equalToSuperview()
            make.top.equalToSuperview().offset(0)
            make.width.equalTo((kScreenW - 48)/3)
        }
        itemViews[1].snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(itemViews[0].snp.right).offset(8)
            make.width.equalTo(itemViews[0])
        }
        itemViews[2].snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(itemViews[1].snp.right).offset(8)
            make.width.equalTo(itemViews[1])
        }
    }
}

// MARK: - 单项视图
private final class OptionItemView: UIView {
    
    private let index: Int
    private let style: TCPriceChooseView.ItemStaticConfig.Style
    
    // 顶部横条（仅 ribbonCard）
    private let ribbonBar = UIView()
    private let ribbonLabel = UILabel()
    private let ribbonIconView = UIImageView()
    
    // 白底卡片
    private let card = UIView()
    private let titleLabel = UILabel()
    let descLabel = UILabel()
    let noteLabel = UILabel()
    
    // 交互
    var onTap: ((Int)->Void)?
    
    init(index: Int,
         style: TCPriceChooseView.ItemStaticConfig.Style,
         mainTitle: String,
         note: String,
         cardCornerRadius: CGFloat,
         cardBorderWidth: CGFloat,
         cardBorderColor: UIColor,
         ribbonIcon: UIImage?) {
        self.index = index
        self.style = style
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        
        // 外层初始底色
        backgroundColor = (style == .plainCard) ? .clear : .systemGray6
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        // 卡片
        card.backgroundColor = .white
        card.layer.cornerRadius = cardCornerRadius
        card.layer.borderWidth = cardBorderWidth
        card.layer.borderColor = UIColor.hexString("#E5FF9D").cgColor
        addSubview(card)
        
        // 文案
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = mainColor
        titleLabel.text = mainTitle
        titleLabel.textAlignment = .center
        
        descLabel.font = .systemFont(ofSize: 13)
        descLabel.textColor = .label
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        
        noteLabel.font = middleFont(fontSize: 14)
        noteLabel.textColor = mainColor
        noteLabel.text = note
        noteLabel.textAlignment = .center
        
        card.addSubview(titleLabel)
        card.addSubview(descLabel)
        card.addSubview(noteLabel)
        
        // 卡片内约束
        card.snp.makeConstraints { make in
            // 有 ribbon 时卡片离顶部多留一点
            
            var topInset: CGFloat =   8
//            if style == .ribbonCard  || style == .thrCard{
                topInset = 34
//            }
            make.top.equalToSuperview().inset(topInset)
            make.left.right.bottom.equalToSuperview().inset(2)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(20)
        }
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.right.equalTo(titleLabel)
        }
        noteLabel.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(6)
            make.left.right.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(20)
        }
        
        // ribbon（仅第2/3项）
//        if style == .ribbonCard || style == .thrCard {
            addSubview(ribbonBar)
            ribbonBar.addSubview(ribbonLabel)
            ribbonBar.addSubview(ribbonIconView)
            
            ribbonBar.backgroundColor = .clear
            var title = "超值".localized()
            if style == .thrCard {
                title = "最多人选".localized()
            }else if style == .ribbonCard {
                title = "最受欢迎".localized()
            }
            
            ribbonLabel.text = title

            ribbonLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            ribbonLabel.textColor = .label
            
            ribbonIconView.contentMode = .scaleAspectFit
            ribbonIconView.tintColor = .label
            ribbonIconView.image = ribbonIcon ?? UIImage(systemName: "checkmark.seal.fill")
            
            ribbonBar.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview().inset(8)
                make.height.equalTo(22)
            }
            ribbonLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.centerX.equalToSuperview().offset(-10)
//                make.left.equalToSuperview().offset(30)
            }
            ribbonIconView.snp.makeConstraints { make in
                make.left.equalTo(ribbonLabel.snp.right).offset(6)
                make.centerY.equalTo(ribbonLabel.snp.centerY)
                make.width.height.equalTo(16)
            }
//        }
        
        // 点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // 外部仅允许改描述
    func setDescription(_ text: String?,type:Int) {
        guard let priceText = text else { return }
        // 使用正则提取货币符号（非数字部分）和金额（数字部分）
        let symbolRegex = "^[^0-9\\.]*"
        let symbol = (priceText as NSString).range(of: symbolRegex, options: .regularExpression)
        let currencySymbol = (symbol.location != NSNotFound) ? (priceText as NSString).substring(with: symbol) : ""
        let amountString = priceText.replacingOccurrences(of: currencySymbol, with: "")
        guard let amount = Double(amountString) else {
                descLabel.text = priceText
                return
            }
            
            var displayAmount: Double = amount
            
            switch type {
            case 0: // 年卡
                displayAmount = amount / (1800 )
            case 1: // 年卡
                displayAmount = amount / (1800 * 12)
            case 2: // 季卡
                displayAmount = amount / (1800 * 3)
            default:
                break
            }
            
            // 保留 3 位小数，四舍五入
            let formattedAmount = String(format: "%.3f", displayAmount)
        noteLabel.text = currencySymbol + formattedAmount + "/分钟".localized()
            
        let attrText = NSMutableAttributedString(
            string: currencySymbol,
            attributes: [
                .font: BoldFont(fontSize: 17),
                .foregroundColor: UIColor.black
            ]
        )
        
        attrText.append(NSAttributedString(
            string: amountString,
            attributes: [
                .font: BoldFont(fontSize: 23),
                .foregroundColor: UIColor.black
            ]
        ))
        
        descLabel.attributedText = attrText
        setNeedsLayout()
    }
    
//    func applySelected(_ selected: Bool,
//                       accent: UIColor,
//                       cardBorderDefault: UIColor,
//                       ribbonBase: UIColor,
//                       ribbonSelectedBase: UIColor) {
////        switch style {
////        case .plainCard:
////            // 第1项：边框变色
////            card.layer.borderColor = selected ? ribbonSelectedBase.cgColor : ribbonBase.cgColor
////            card.layer.borderWidth = selected ? 4 : 1
////
////        case .ribbonCard,.thrCard:
//            // 第2/3项：外层底色变色
//            backgroundColor = selected ? ribbonSelectedBase : ribbonBase
//            // 可选：让 ribbon 更强调
//            ribbonLabel.textColor = selected ? accent : .label
//            ribbonIconView.tintColor = selected ? accent : .label
//            // 卡片边框不变
//            card.layer.borderColor = selected ? ribbonSelectedBase.cgColor : ribbonBase.cgColor
//            card.layer.borderWidth = 1
////        }
//    }
    func applySelected(_ selected: Bool,
                       accent: UIColor,
                       cardBorderDefault: UIColor,
                       ribbonBase: UIColor,
                       ribbonSelectedBase: UIColor) {
        // 选中态/非选中态的缩放比例
        let targetTransform: CGAffineTransform = selected ? CGAffineTransform(scaleX: 1.08, y: 1.08) : CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.6,
                       options: [.curveEaseInOut],
                       animations: {
            self.transform = targetTransform
            self.backgroundColor = selected ? ribbonSelectedBase : ribbonBase
            self.ribbonLabel.textColor = selected ? accent : .label
            self.ribbonIconView.tintColor = selected ? accent : .label
            self.card.layer.borderColor = selected ? ribbonSelectedBase.cgColor : ribbonBase.cgColor
        }, completion: nil)
    }

    
    @objc private func onTapped() { onTap?(index) }
}
