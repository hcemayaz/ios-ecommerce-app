import UIKit

final class CustomerFormViewController: UIViewController {

    var onSave: ((CustomerRequest) -> Void)?

    private let firstNameField = FormTextField(placeholder: "Ad")
    private let lastNameField = FormTextField(placeholder: "Soyad")
    private let emailField = FormTextField(placeholder: "E-posta")
    private let phoneField = FormTextField(placeholder: "Telefon (opsiyonel)")

    private var editingCustomer: CustomerResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = editingCustomer != nil ? "Müşteri Düzenle" : "Yeni Müşteri"
        view.backgroundColor = .systemBackground
        emailField.keyboardType = .emailAddress
        phoneField.keyboardType = .phonePad
        setupUI()
        setupNavigationBar()
    }

    func prefill(with customer: CustomerResponse) {
        editingCustomer = customer
        firstNameField.text = customer.firstName
        lastNameField.text = customer.lastName
        emailField.text = customer.email
        phoneField.text = customer.phone
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Kaydet", style: .done, target: self, action: #selector(saveTapped))
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [firstNameField, lastNameField, emailField, phoneField])
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
        guard let firstName = firstNameField.text, !firstName.isEmpty,
              let lastName = lastNameField.text, !lastName.isEmpty,
              let email = emailField.text, !email.isEmpty else {
            let alert = UIAlertController(title: "Hata", message: "Ad, Soyad ve E-posta zorunludur.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        }

        let phone = phoneField.text?.isEmpty == true ? nil : phoneField.text
        let request = CustomerRequest(firstName: firstName, lastName: lastName, email: email, phone: phone)
        onSave?(request)
        navigationController?.popViewController(animated: true)
    }
}
