import UIKit

final class OrderFormViewController: UIViewController {

    var onSave: ((OrderRequest) -> Void)?

    private let customerIdField = FormTextField(placeholder: "Müşteri ID")
    private let addItemButton = UIButton(type: .system)
    private let itemsStack = UIStackView()
    private var orderItems: [(productIdField: FormTextField, quantityField: FormTextField)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Yeni Sipariş"
        view.backgroundColor = .systemBackground
        customerIdField.keyboardType = .numberPad
        setupUI()
        setupNavigationBar()
        addItemRow()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Kaydet", style: .done, target: self, action: #selector(saveTapped))
    }

    private func setupUI() {
        addItemButton.setTitle("+ Ürün Ekle", for: .normal)
        addItemButton.addTarget(self, action: #selector(addItemRow), for: .touchUpInside)

        itemsStack.axis = .vertical
        itemsStack.spacing = 12

        let mainStack = UIStackView(arrangedSubviews: [customerIdField, itemsStack, addItemButton])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            mainStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            mainStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    @objc private func addItemRow() {
        let productIdField = FormTextField(placeholder: "Ürün ID")
        productIdField.keyboardType = .numberPad
        let quantityField = FormTextField(placeholder: "Adet")
        quantityField.keyboardType = .numberPad

        let row = UIStackView(arrangedSubviews: [productIdField, quantityField])
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fillEqually

        itemsStack.addArrangedSubview(row)
        orderItems.append((productIdField, quantityField))
    }

    @objc private func saveTapped() {
        guard let customerIdText = customerIdField.text, let customerId = Int(customerIdText) else {
            showAlert("Lütfen geçerli bir Müşteri ID girin.")
            return
        }

        var items: [OrderItemRequest] = []
        for item in orderItems {
            guard let pidText = item.productIdField.text, let pid = Int(pidText),
                  let qtyText = item.quantityField.text, let qty = Int(qtyText), qty > 0 else {
                continue
            }
            items.append(OrderItemRequest(productId: pid, quantity: qty))
        }

        guard !items.isEmpty else {
            showAlert("En az bir ürün eklemelisiniz.")
            return
        }

        let request = OrderRequest(customerId: customerId, items: items)
        onSave?(request)
        navigationController?.popViewController(animated: true)
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}
