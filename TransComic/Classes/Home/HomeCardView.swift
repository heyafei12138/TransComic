
import UIKit

class HomeCardView: UIView {
   let bgImageView = UIImageView()
   let titleLabel = UILabel()
   let descLabel = UILabel()
   let demoImageView = UIImageView()
   let startButton = UIButton(type: .system)
    let lottview = LottieAndTitleView()
    var onTap: (() -> Void)?
    
   override init(frame: CGRect) {
       super.init(frame: frame)
       setupUI()
   }
   
   required init?(coder: NSCoder) {
       super.init(coder: coder)
       setupUI()
   }
   
   private func setupUI() {
       layer.cornerRadius = 13
       layer.masksToBounds = true
       
       bgImageView.contentMode = .scaleToFill
//       bgImageView.clipsToBounds = true
//       bgImageView.layer.cornerRadius = 26
       addSubview(bgImageView)
       bgImageView.translatesAutoresizingMaskIntoConstraints = false
       NSLayoutConstraint.activate([
           bgImageView.topAnchor.constraint(equalTo: topAnchor),
           bgImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
           bgImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
           bgImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
       ])
       
       titleLabel.font = BoldFont(fontSize: 18)
       titleLabel.textColor = .black
       addSubview(titleLabel)
       titleLabel.translatesAutoresizingMaskIntoConstraints = false
       NSLayoutConstraint.activate([
           titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
           titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
           titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -140)
       ])
       
       descLabel.font = middleFont(fontSize: 14)
       descLabel.textColor = black
       descLabel.numberOfLines = 2
       addSubview(descLabel)
       descLabel.translatesAutoresizingMaskIntoConstraints = false
       NSLayoutConstraint.activate([
           descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
           descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
           descLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
       ])
       
       demoImageView.contentMode = .scaleAspectFit
       addSubview(demoImageView)
       demoImageView.translatesAutoresizingMaskIntoConstraints = false
       NSLayoutConstraint.activate([
            demoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            demoImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
           demoImageView.widthAnchor.constraint(equalToConstant: 100),
           demoImageView.heightAnchor.constraint(equalToConstant: 100)
       ])

       
       
       lottview.title = "立即开始".localized()
       lottview.onTap = {
           self.onTap?()
       }
       addSubview(lottview)
       lottview.snp.makeConstraints { make in
           make.bottom.equalToSuperview().offset(-20)
           make.left.equalToSuperview().offset(20)
           make.right.lessThanOrEqualToSuperview().offset(-120) // 限制最大宽度
           make.height.equalTo(36)
        }
       
       
   }
   
    func configure(bgImage: UIImage?, title: String, desc: String, demoImage: UIImage?,btnColor:UIColor,lottiStr:String = "web") {
       let image = bgImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 50, left: 100, bottom: 50, right: 100), resizingMode: .stretch)
       bgImageView.image = image
       titleLabel.text = title
       descLabel.text = desc
       demoImageView.image = demoImage
        lottview.backgroundColor = btnColor
        lottview.animationName = lottiStr
   }
}
