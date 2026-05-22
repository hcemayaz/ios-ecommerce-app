import UIKit

final class OrderCell: UITableViewCell {

    static let identifier = "OrderCell"

    private let orderIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    private let customerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .right
        return label
    }()

    private let statusBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.textColor = .white
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let leftStack = UIStackView(arrangedSubviews: [orderIdLabel, customerLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4

        let rightStack = UIStackView(arrangedSubviews: [totalLabel, statusBadge])
        rightStack.axis = .vertical
        rightStack.spacing = 4
        rightStack.alignment = .trailing

        let mainStack = UIStackView(arrangedSubviews: [leftStack, rightStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            statusBadge.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    func configure(with order: OrderResponse) {
        orderIdLabel.text = "Sipariş #\(order.id)"
        customerLabel.text = order.customerName
        totalLabel.text = String(format: "₺%.2f", order.totalAmount)
        statusBadge.text = statusText(order.status)
        statusBadge.backgroundColor = statusColor(order.status)
    }

    private func statusText(_ status: OrderStatus) -> String {
        switch status {
        case .PENDING: return "Beklemede"
        case .SHIPPED: return "Kargoda"
        case .DELIVERED: return "Teslim"
        case .CANCELLED: return "İptal"
        }
    }

    private func statusColor(_ status: OrderStatus) -> UIColor {
        switch status {
        case .PENDING: return .systemOrange
        case .SHIPPED: return .systemBlue
        case .DELIVERED: return .systemGreen
        case .CANCELLED: return .systemRed
        }
    }
}
