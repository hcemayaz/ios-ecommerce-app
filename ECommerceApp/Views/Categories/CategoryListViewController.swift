import UIKit

final class CategoryListViewController: UIViewController {

    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let viewModel = CategoryViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Kategoriler"
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupTableView()
        setupActivityIndicator()
        viewModel.delegate = self
        viewModel.fetchCategories()
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCategoryTapped)
        )
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
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

    @objc private func addCategoryTapped() {
        let alert = UIAlertController(title: "Yeni Kategori", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Kategori Adı" }
        alert.addTextField { $0.placeholder = "Üst Kategori ID (opsiyonel)"; $0.keyboardType = .numberPad }
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Kaydet", style: .default) { [weak self] _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty else { return }
            var parentId: Int?
            if let parentText = alert.textFields?[1].text, let pid = Int(parentText) {
                parentId = pid
            }
            self?.viewModel.createCategory(CategoryRequest(name: name, parentId: parentId))
        })
        present(alert, animated: true)
    }

    @objc private func refreshData() {
        viewModel.fetchCategories()
    }
}

extension CategoryListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = viewModel.categories[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = category.name
        if let parentId = category.parentId {
            content.secondaryText = "Üst Kategori ID: \(parentId)"
        }
        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let category = viewModel.categories[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, completion in
            self?.viewModel.deleteCategory(id: category.id)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension CategoryListViewController: CategoryViewModelDelegate {
    func didUpdateCategories() {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
        tableView.reloadData()
    }

    func didFailWithError(_ error: NetworkError) {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
        let alert = UIAlertController(title: "Hata", message: error.errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    func didDeleteCategory() {}
}
