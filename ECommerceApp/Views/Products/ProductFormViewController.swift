import UIKit

final class ProductFormViewController: UIViewController {

    var onSave: ((ProductRequest) -> Void)?

    private let nameField = FormTextField(placeholder: "Ürün Adı")
    private let skuField = FormTextField(placeholder: "SKU")
    private let priceField = FormTextField(placeholder: "Fiyat")
    private let stockField = FormTextField(placeholder: "Stok Miktarı")
    private let activeSwitch = UISwitch()
    private let categoryIdField = FormTextField(placeholder: "Kategori ID (opsiyonel)")

    private var editingProduct: ProductResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = editingProduct != nil ? "Ürün Düzenle" : "Yeni Ürün"
        view.backgroundColor = .systemBackground
        setupUI()
        setupNavigationBar()
    }

    func prefill(with product: ProductResponse) {
        editingProduct = product
        nameField.text = product.name
        skuField.text = product.sku
        priceField.text = "\(product.price)"
        stockField.text = "\(product.stockQuantity)"
        activeSwitch.isOn = product.active
        if let catId = product.categoryId {
            categoryIdField.text = "\(catId)"
        }
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Kaydet", style: .done, target: self, action: #selector(saveTapped))
    }

    private func setupUI() {
        priceField.keyboardType = .decimalPad
        stockField.keyboardType = .numberPad
        categoryIdField.keyboardType = .numberPad

        let activeLabel = UILabel()
        activeLabel.text = "Aktif"
        activeSwitch.isOn = true

        let activeRow = UIStackView(arrangedSubviews: [activeLabel, activeSwitch])
        activeRow.axis = .horizontal
        activeRow.spacing = 8

        let stack = UIStackView(arrangedSubviews: [
            nameField, skuField, priceField, stockField, activeRow, categoryIdField
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func saveTapped() {
        guard let name = nameField.text, !name.isEmpty,
              let sku = skuField.text, !sku.isEmpty,
              let priceText = priceField.text, let price = Double(priceText),
              let stockText = stockField.text, let stock = Int(stockText) else {
            let alert = UIAlertController(title: "Hata", message: "Lütfen tüm zorunlu alanları doldurun.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        }

        var categoryId: Int?
        if let catText = categoryIdField.text, let catId = Int(catText) {
            categoryId = catId
        }

        let request = ProductRequest(
            name: name,
            sku: sku,
            price: price,
            stockQuantity: stock,
            active: activeSwitch.isOn,
            categoryId: categoryId
        )
        onSave?(request)
        navigationController?.popViewController(animated: true)
    }
}
