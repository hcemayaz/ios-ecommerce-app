import UIKit

final class OrderListViewController: UIViewController {

    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let viewModel = OrderViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Siparişler"
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupTableView()
        setupActivityIndicator()
        viewModel.delegate = self
        viewModel.fetchOrders()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addOrderTapped)
        )
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.identifier)
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

    @objc private func addOrderTapped() {
        let formVC = OrderFormViewController()
        formVC.onSave = { [weak self] request in
            self?.viewModel.createOrder(request)
        }
        navigationController?.pushViewController(formVC, animated: true)
    }

    @objc private func refreshData() {
        viewModel.fetchOrders()
    }
}

extension OrderListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.identifier, for: indexPath) as? OrderCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.orders[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let order = viewModel.orders[indexPath.row]
        let detailVC = OrderDetailViewController(order: order)
        detailVC.onStatusChange = { [weak self] status in
            self?.viewModel.updateOrderStatus(id: order.id, status: status)
        }
        detailVC.onDelete = { [weak self] in
            self?.viewModel.deleteOrder(id: order.id)
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

extension OrderListViewController: OrderViewModelDelegate {
    func didUpdateOrders() {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
        tableView.reloadData()
    }

    func didSelectOrder(_ order: OrderResponse) {}

    func didFailWithError(_ error: NetworkError) {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
        let alert = UIAlertController(title: "Hata", message: error.errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    func didDeleteOrder() {}
}
