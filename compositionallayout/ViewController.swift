//
//  ViewController.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import UIKit

class ViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var popularMovies: [MovieModel] = []
    private var upcomingMovies: [MovieModel] = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, MovieModel>!
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner
    }()

    private enum Section: Int, CaseIterable {
        case popular
        case upcoming

        var title: String {
            switch self {
            case .popular: return "Popular"
            case .upcoming: return "Upcoming"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchMovies()
        view.addSubview(loadingIndicator)
        loadingIndicator.center = view.center
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

        dataSource = UICollectionViewDiffableDataSource<Section, MovieModel>(collectionView: collectionView) {
            (collectionView, indexPath, movie) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
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

            if let section = Section(rawValue: indexPath.section) {
                headerView.configure(with: section.title)
            }

            return headerView
        }
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let sectionType = Section(rawValue: sectionIndex) else { return nil }

            // Define header size
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.pinToVisibleBounds = true

            var section: NSCollectionLayoutSection

            switch sectionType {
            case .popular:
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(140), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(140), heightDimension: .absolute(220))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10

            case .upcoming:
                // Ukuran item untuk 3 kolom
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0 / 3.0),
                    heightDimension: .estimated(320)  // estimasi tinggi, bisa naik sesuai konten
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(320)  // group juga pakai estimated
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item, item])

                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
            }

            section.boundarySupplementaryItems = [header]
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
            return section
        }
    }

    private func fetchMovies() {
        showLoading(true)
        let apiManager = APIManager()
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        apiManager.fetchMovies(endpoint: "/movie/popular") { movies in
            self.popularMovies = movies
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        apiManager.fetchMovies(endpoint: "/movie/upcoming") { movies in
            self.upcomingMovies = movies
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            self.updateDataSource()
            self.showLoading(false)
        }
    }

    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieModel>()
        snapshot.appendSections([.popular, .upcoming])
        snapshot.appendItems(popularMovies, toSection: .popular)
        snapshot.appendItems(upcomingMovies, toSection: .upcoming)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

