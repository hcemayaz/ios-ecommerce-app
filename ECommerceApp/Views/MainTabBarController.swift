import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    private func setupTabs() {
        let productsVC = UINavigationController(rootViewController: ProductListViewController())
        productsVC.tabBarItem = UITabBarItem(title: "Ürünler", image: UIImage(systemName: "bag"), tag: 0)

        let categoriesVC = UINavigationController(rootViewController: CategoryListViewController())
        categoriesVC.tabBarItem = UITabBarItem(title: "Kategoriler", image: UIImage(systemName: "square.grid.2x2"), tag: 1)

        let customersVC = UINavigationController(rootViewController: CustomerListViewController())
        customersVC.tabBarItem = UITabBarItem(title: "Müşteriler", image: UIImage(systemName: "person.2"), tag: 2)

        let ordersVC = UINavigationController(rootViewController: OrderListViewController())
        ordersVC.tabBarItem = UITabBarItem(title: "Siparişler", image: UIImage(systemName: "cart"), tag: 3)

        let assistantVC = UINavigationController(rootViewController: AssistantViewController())
        assistantVC.tabBarItem = UITabBarItem(title: "Asistan", image: UIImage(systemName: "message"), tag: 4)

        viewControllers = [productsVC, categoriesVC, customersVC, ordersVC, assistantVC]
    }

    private func setupAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
    }
}
