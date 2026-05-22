import UIKit

final class ProductDetailViewController: UIViewController {

    private let product: ProductResponse
    var onDelete: (() -> Void)?
    var onUpdate: ((ProductRequest) -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    init(product: ProductResponse) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = product.name
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped)),
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
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

        addDetailRow("Ürün Adı", value: product.name)
        addDetailRow("SKU", value: product.sku)
        addDetailRow("Fiyat", value: String(format: "₺%.2f", product.price))
        addDetailRow("Stok", value: "\(product.stockQuantity)")
        addDetailRow("Durum", value: product.active ? "Aktif" : "Pasif")
        addDetailRow("Kategori", value: product.categoryName ?? "—")
        addDetailRow("Oluşturulma", value: product.createdAt ?? "—")
        addDetailRow("Güncellenme", value: product.updatedAt ?? "—")
    }

    private func addDetailRow(_ title: String, value: String) {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title

        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 17, weight: .regular)
        valueLabel.text = value
        valueLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        contentStack.addArrangedSubview(stack)
    }

    @objc private func editTapped() {
        let formVC = ProductFormViewController()
        formVC.prefill(with: product)
        formVC.onSave = { [weak self] request in
            self?.onUpdate?(request)
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(formVC, animated: true)
    }

    @objc private func deleteTapped() {
        let alert = UIAlertController(title: "Sil", message: "Bu ürünü silmek istediğinize emin misiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            self?.onDelete?()
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
