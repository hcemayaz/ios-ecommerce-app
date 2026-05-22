import UIKit

final class OrderDetailViewController: UIViewController {

    private let order: OrderResponse
    var onStatusChange: ((OrderStatus) -> Void)?
    var onDelete: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    init(order: OrderResponse) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sipariş #\(order.id)"
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped)),
            UIBarButtonItem(title: "Durum", style: .plain, target: self, action: #selector(changeStatusTapped))
        ]
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        addRow("Müşteri", value: order.customerName)
        addRow("Durum", value: statusText(order.status))
        addRow("Toplam", value: String(format: "₺%.2f", order.totalAmount))
        addRow("Tarih", value: order.createdAt ?? "—")

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentStack.addArrangedSubview(separator)

        let itemsTitle = UILabel()
        itemsTitle.text = "Sipariş Kalemleri"
        itemsTitle.font = .systemFont(ofSize: 18, weight: .bold)
        contentStack.addArrangedSubview(itemsTitle)

        for item in order.items {
            let itemView = createItemRow(item)
            contentStack.addArrangedSubview(itemView)
        }
    }

    private func addRow(_ title: String, value: String) {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title

        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 17)
        valueLabel.text = value

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        contentStack.addArrangedSubview(stack)
    }

    private func createItemRow(_ item: OrderItemResponse) -> UIView {
        let nameLabel = UILabel()
        nameLabel.text = item.productName
        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)

        let detailLabel = UILabel()
        detailLabel.text = "\(item.quantity) x \(String(format: "₺%.2f", item.unitPrice))"
        detailLabel.font = .systemFont(ofSize: 13)
        detailLabel.textColor = .secondaryLabel

        let totalLabel = UILabel()
        totalLabel.text = String(format: "₺%.2f", item.lineTotal)
        totalLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        totalLabel.textAlignment = .right

        let leftStack = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 2

        let row = UIStackView(arrangedSubviews: [leftStack, totalLabel])
        row.axis = .horizontal
        row.spacing = 8
        return row
    }

    private func statusText(_ status: OrderStatus) -> String {
        switch status {
        case .PENDING: return "Beklemede"
        case .SHIPPED: return "Kargoda"
        case .DELIVERED: return "Teslim Edildi"
        case .CANCELLED: return "İptal Edildi"
        }
    }

    @objc private func changeStatusTapped() {
        let alert = UIAlertController(title: "Sipariş Durumu", message: "Yeni durumu seçin", preferredStyle: .actionSheet)
        for status in [OrderStatus.PENDING, .SHIPPED, .DELIVERED, .CANCELLED] {
            alert.addAction(UIAlertAction(title: statusText(status), style: status == .CANCELLED ? .destructive : .default) { [weak self] _ in
                self?.onStatusChange?(status)
                self?.navigationController?.popViewController(animated: true)
            })
        }
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func deleteTapped() {
        let alert = UIAlertController(title: "Sil", message: "Bu siparişi silmek istediğinize emin misiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            self?.onDelete?()
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
