 
import UIKit

class HomeHistoryCell: UITableViewCell {
    let iconView = UIImageView()
    let titleLabel = UILabel()
    let categoryLabel = UILabel()
    let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        categoryLabel.font = UIFont.systemFont(ofSize: 12)
        categoryLabel.textColor = mainColor
        categoryLabel.backgroundColor = mainColor.withAlphaComponent(0.1)
        categoryLabel.textAlignment = .center
        categoryLabel.layer.cornerRadius = 8
        categoryLabel.layer.masksToBounds = true
        contentView.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            categoryLabel.widthAnchor.constraint(equalToConstant: 60),
            categoryLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .gray
        contentView.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 8),
            timeLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(icon: UIImage?, title: String, category: String, time: String) {
        iconView.image = icon
        titleLabel.text = title
        categoryLabel.text = category
        timeLabel.text = time
    }
    
    func configure(with history: HomeHistoryModel) {
        iconView.image = history.getImage()
        titleLabel.text = history.title
        categoryLabel.text = history.category
        
        // 格式化时间
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: history.createdAt)
    }
}
