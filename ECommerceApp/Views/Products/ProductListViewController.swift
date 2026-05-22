import UIKit

final class ProductListViewController: UIViewController {

    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let viewModel = ProductViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ürünler"
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupTableView()
        setupActivityIndicator()
        viewModel.delegate = self
        viewModel.fetchProducts()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addProductTapped)
        )
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }

    @objc private func addProductTapped() {
        let formVC = ProductFormViewController()
        formVC.onSave = { [weak self] request in
            self?.viewModel.createProduct(request)
        }
        navigationController?.pushViewController(formVC, animated: true)
    }

    @objc private func refreshData() {
        viewModel.fetchProducts()
    }

    private func showError(_ error: NetworkError) {
        let alert = UIAlertController(title: "Hata", message: error.errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ProductListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.identifier, for: indexPath) as? ProductCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.products[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = viewModel.products[indexPath.row]
        let detailVC = ProductDetailViewController(product: product)
        detailVC.onDelete = { [weak self] in
            self?.viewModel.deleteProduct(id: product.id)
        }
        detailVC.onUpdate = { [weak self] request in
            self?.viewModel.updateProduct(id: product.id, request: request)
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

// MARK: - ProductViewModelDelegate

extension ProductListViewController: ProductViewModelDelegate {
    func didUpdateProducts() {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
        tableView.reloadData()
    }

    func didSelectProduct(_ product: ProductResponse) {}

    func didFailWithError(_ error: NetworkError) {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
        showError(error)
    }

    func didDeleteProduct() {}
}
