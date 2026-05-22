import UIKit

final class CustomerListViewController: UIViewController {

    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let viewModel = CustomerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Müşteriler"
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupTableView()
        setupActivityIndicator()
        viewModel.delegate = self
        viewModel.fetchCustomers()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCustomerTapped)
        )
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CustomerCell")
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

    @objc private func addCustomerTapped() {
        let formVC = CustomerFormViewController()
        formVC.onSave = { [weak self] request in
            self?.viewModel.createCustomer(request)
        }
        navigationController?.pushViewController(formVC, animated: true)
    }

    @objc private func refreshData() {
        viewModel.fetchCustomers()
    }
}

extension CustomerListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.customers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)
        let customer = viewModel.customers[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = "\(customer.firstName) \(customer.lastName)"
        content.secondaryText = customer.email
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let customer = viewModel.customers[indexPath.row]
        let detailVC = CustomerDetailViewController(customer: customer)
        detailVC.onDelete = { [weak self] in
            self?.viewModel.deleteCustomer(id: customer.id)
        }
        detailVC.onUpdate = { [weak self] request in
            self?.viewModel.updateCustomer(id: customer.id, request: request)
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let customer = viewModel.customers[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, completion in
            self?.viewModel.deleteCustomer(id: customer.id)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension CustomerListViewController: CustomerViewModelDelegate {
    func didUpdateCustomers() {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
        tableView.reloadData()
    }

    func didSelectCustomer(_ customer: CustomerResponse) {}

    func didFailWithError(_ error: NetworkError) {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
        let alert = UIAlertController(title: "Hata", message: error.errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    func didDeleteCustomer() {}
}
