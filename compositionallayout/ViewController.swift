//
//  ViewController.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import UIKit
import Combine

class ViewController: UIViewController {

    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var viewModel: MovieListViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var errorView: ErrorView?
    private var dataSource: UICollectionViewDiffableDataSource<Int, Movie>!

    private let loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupViewModel()
        viewModel.fetchMovies()
        view.addSubview(loadingIndicator)
        loadingIndicator.center = view.center
    }

    // MARK: - Setup
    private func setupViewModel() {
        let repository = MovieRepository()
        let fetchMoviesUseCase = FetchMoviesUseCase(repository: repository)
        let searchMoviesUseCase = SearchMoviesUseCase(repository: repository)
        viewModel = MovieListViewModel(fetchMoviesUseCase: fetchMoviesUseCase,
                                       searchMoviesUseCase: searchMoviesUseCase)
        bindViewModel()
    }

    private func setupCollectionView() {
        let layout = createCompositionalLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        collectionView.register(SectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        view.addSubview(collectionView)

        dataSource = UICollectionViewDiffableDataSource<Int, Movie>(collectionView: collectionView) {
            (collectionView, indexPath, movie) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as? MovieCell else {
                return UICollectionViewCell()
            }

            // Configure cell with domain model
            cell.configure(with: movie)
            return cell
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let headerView = collectionView.dequeueReusableSupplementaryView(
                      ofKind: kind,
                      withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                      for: indexPath
                  ) as? SectionHeaderView else {
                return nil
            }

            let section = indexPath.section
            if section == 0 {
                headerView.configure(with: "Popular")
            } else {
                headerView.configure(with: "Upcoming")
            }

            return headerView
        }
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            // Define header size
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.pinToVisibleBounds = false

            var section: NSCollectionLayoutSection

            switch sectionIndex {
            case 0: // Popular movies
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(140), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(140), heightDimension: .absolute(230))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10

            case 1: // Upcoming movies
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 3.0), heightDimension: .estimated(320))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(320))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item, item])

                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8

            default:
                return nil
            }

            section.boundarySupplementaryItems = [header]
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
            return section
        }
    }

    // MARK: - Binding
    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.showLoading(isLoading)
            }
            .store(in: &cancellables)

        viewModel.$popularMovies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDataSource()
            }
            .store(in: &cancellables)

        viewModel.$upcomingMovies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDataSource()
            }
            .store(in: &cancellables)

        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showError(error)
                } else {
                    self?.hideError()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Error Handling
    private func showError(_ error: NetworkError) {
        errorView?.removeFromSuperview()
        errorView = ErrorView()
        errorView?.configure(with: error)
        errorView?.delegate = self
        errorView?.show(in: view)
    }

    private func hideError() {
        errorView?.hide()
        errorView = nil
    }

    // MARK: - Data Source
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
        snapshot.appendSections([0, 1]) // 0 for popular, 1 for upcoming
        snapshot.appendItems(viewModel.popularMovies, toSection: 0)
        snapshot.appendItems(viewModel.upcomingMovies, toSection: 1)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func showLoading(_ show: Bool) {
        if show {
            loadingIndicator.startAnimating()
            collectionView.alpha = 0.2
        } else {
            loadingIndicator.stopAnimating()
            collectionView.alpha = 1.0
        }
    }
}

// MARK: - ErrorViewDelegate
extension ViewController: ErrorViewDelegate {
    func errorViewDidTapRetry(_ errorView: ErrorView) {
        viewModel.retry()
    }
}

