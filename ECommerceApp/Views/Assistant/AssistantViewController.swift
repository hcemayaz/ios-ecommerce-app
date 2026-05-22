import UIKit

final class AssistantViewController: UIViewController {

    private let viewModel = AssistantViewModel()

    private let messageField: UITextField = {
        let field = UITextField()
        field.placeholder = "Bir şey sorun..."
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 16)
        field.returnKeyType = .send
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Gönder", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let responseTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.font = .systemFont(ofSize: 15)
        tv.textColor = .label
        tv.layer.borderColor = UIColor.separator.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let productsTableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isHidden = true
        return tv
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var recommendedProducts: [ProductResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AI Asistan"
        view.backgroundColor = .systemBackground
        viewModel.delegate = self
        setupUI()
    }

    private func setupUI() {
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        productsTableView.dataSource = self
        productsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecProductCell")

        let inputStack = UIStackView(arrangedSubviews: [messageField, sendButton])
        inputStack.axis = .horizontal
        inputStack.spacing = 8
        inputStack.translatesAutoresizingMaskIntoConstraints = false

        let recommendedLabel = UILabel()
        recommendedLabel.text = "Önerilen Ürünler"
        recommendedLabel.font = .systemFont(ofSize: 16, weight: .bold)
        recommendedLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(inputStack)
        view.addSubview(activityIndicator)
        view.addSubview(responseTextView)
        view.addSubview(recommendedLabel)
        view.addSubview(productsTableView)

        NSLayoutConstraint.activate([
            inputStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            inputStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sendButton.widthAnchor.constraint(equalToConstant: 70),

            activityIndicator.topAnchor.constraint(equalTo: inputStack.bottomAnchor, constant: 12),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            responseTextView.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 12),
            responseTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            responseTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            responseTextView.heightAnchor.constraint(equalToConstant: 200),

            recommendedLabel.topAnchor.constraint(equalTo: responseTextView.bottomAnchor, constant: 16),
            recommendedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            productsTableView.topAnchor.constraint(equalTo: recommendedLabel.bottomAnchor, constant: 8),
            productsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func sendTapped() {
        guard let message = messageField.text, !message.isEmpty else { return }
        messageField.resignFirstResponder()
        activityIndicator.startAnimating()
        responseTextView.text = ""
        recommendedProducts = []
        productsTableView.isHidden = true
        productsTableView.reloadData()
        viewModel.sendMessage(message)
    }
}

extension AssistantViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recommendedProducts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecProductCell", for: indexPath)
        let product = recommendedProducts[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = product.name
        content.secondaryText = String(format: "₺%.2f", product.price)
        cell.contentConfiguration = content
        return cell
    }
}

extension AssistantViewController: AssistantViewModelDelegate {
    func didReceiveResponse(_ response: AssistantResponse) {
        activityIndicator.stopAnimating()
        responseTextView.text = response.answer

        if let products = response.recommendedProducts, !products.isEmpty {
            recommendedProducts = products
            productsTableView.isHidden = false
            productsTableView.reloadData()
        }
    }

    func didFailWithError(_ error: NetworkError) {
        activityIndicator.stopAnimating()
        responseTextView.text = "Hata: \(error.errorDescription ?? "Bilinmeyen hata")"
    }
}
