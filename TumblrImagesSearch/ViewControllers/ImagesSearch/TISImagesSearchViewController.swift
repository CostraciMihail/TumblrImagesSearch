//
//  TISImagesSearchViewController.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 07.02.2022.
//

import UIKit
import Combine

/// TISImageDetailsViewController
class TISImagesSearchViewController: UIViewController {

    typealias DataSource = UITableViewDiffableDataSource<ImageSection, ImageItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<ImageSection, ImageItem>

    /// LayoutConstant
    enum LayoutConstant {
        static let tableHeaderHeight: CGFloat = 30
    }

    // MARK: - Properties

    private var searchBar: UISearchBar = {
        $0.frame = .zero
        $0.showsCancelButton = true
        return $0
    }(UISearchBar())

    private let tableView = UITableView(frame: .zero, style: .plain)
    private lazy var dataSource = createDataSource()

    private var viewModel: TISImagesSearchViewModel
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModle: TISImagesSearchViewModel) {
        self.viewModel = viewModle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    // MARK: - UI Setup

    func setupUI() {
        title = "Search Image"
        view.backgroundColor = .white
        setupSearchBar()
        setupTableView()
    }

    func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.backgroundColor = .white
        tableView.separatorInset = .zero
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()

        tableView.register(TISImageCell.self, forCellReuseIdentifier: TISImageCell.identifier)
        tableView.register(TISSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: TISSectionHeaderView.identifier)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0)
        ])
    }

    // MARK: - Binding

    func bind() {
        viewModel.$foundImages
            .dropFirst()
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    guard let self = self else { return }
                    showMessage("Error", message: error.localizedDescription, from: self)
                }
            } receiveValue: { [weak self] results in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.reloadTableView()
                }
            }.store(in: &cancelBag)
    }

}

// MARK: - UISearchBarDelegate

extension TISImagesSearchViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.removeFoundedImages()
        searchBar.text?.removeAll()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        viewModel.searchImages(withTag: searchText)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.removeFoundedImages()
        }
    }
}

// MARK: - UITableViewDelegate

extension TISImagesSearchViewController: UITableViewDelegate {

    private func createDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView,
                                    cellProvider: { [weak self] tableView, indexPath, item in

            guard let self = self else { return UITableViewCell() }
            return self.setUpCell(tableView: tableView, indexPath: indexPath, item: item)
        })

        dataSource.defaultRowAnimation = .fade
        return dataSource
    }

    func reloadTableView() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.items, toSection: .main)
        tableView.reloadData()
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func reloadHeader() {
        var snapshot = Snapshot()
        snapshot.reloadSections(snapshot.sectionIdentifiers)
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row <= viewModel.items.count - 1 else { return }
        openImageDetailsScreen(item: viewModel.items[indexPath.row])
    }

    func setUpCell(tableView: UITableView, indexPath: IndexPath, item: ImageItem) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: TISImageCell.identifier,
                                                       for: indexPath) as? TISImageCell else {
            return UITableViewCell()
        }

        cell.configure(with: nil)

        self.viewModel.service.downloaImage(from: item.url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { image in
                guard let cell = self.tableView.cellForRow(at: indexPath) as? TISImageCell else { return
                }
                cell.configure(with: image)
            }).store(in: &self.cancelBag)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TISSectionHeaderView.identifier) as? TISSectionHeaderView else { return nil }

        header.title.text = "Found \(viewModel.items.count) items"
        header.title.textColor = .black
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return LayoutConstant.tableHeaderHeight
    }
}

// MARK: - Navigation

extension TISImagesSearchViewController {
    func openImageDetailsScreen(item: ImageItem) {
        guard let navVC = navigationController else { return }

        let viewModel = TISImageDetailsViewModel(item: item)
        let vc = TISImageDetailsViewController(viewModle: viewModel)

        DispatchQueue.main.async {
            navVC.pushViewController(vc, animated: true)
        }
    }
}
