import UIKit

final class CustomerDetailViewController: UIViewController {

    private let customer: CustomerResponse
    var onDelete: (() -> Void)?
    var onUpdate: ((CustomerRequest) -> Void)?

    private let contentStack = UIStackView()

    init(customer: CustomerResponse) {
        self.customer = customer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(customer.firstName) \(customer.lastName)"
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
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        addRow("Ad", value: customer.firstName)
        addRow("Soyad", value: customer.lastName)
        addRow("E-posta", value: customer.email)
        addRow("Telefon", value: customer.phone ?? "—")
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

    @objc private func editTapped() {
        let formVC = CustomerFormViewController()
        formVC.prefill(with: customer)
        formVC.onSave = { [weak self] request in
            self?.onUpdate?(request)
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(formVC, animated: true)
    }

    @objc private func deleteTapped() {
        let alert = UIAlertController(title: "Sil", message: "Bu müşteriyi silmek istediğinize emin misiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            self?.onDelete?()
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
