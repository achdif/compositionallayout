//
//  ErrorView.swift
//  compositionallayout
//
//  Created by achdi on 12/06/25.
//

import UIKit

public protocol ErrorViewDelegate: AnyObject {
    func errorViewDidTapRetry(_ errorView: ErrorView)
}

public class ErrorView: UIView {

    // MARK: - Properties
    public weak var delegate: ErrorViewDelegate?

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemRed
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Try Again", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .systemBackground
        addSubview(stackView)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(retryButton)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),

            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            retryButton.widthAnchor.constraint(equalToConstant: 120),
            retryButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Configuration
    public func configure(with error: NetworkError) {
        titleLabel.text = error.title
        messageLabel.text = error.errorDescription

        // Set image based on error type
        let imageName = error.imageName
        if let image = UIImage(systemName: imageName) {
            imageView.image = image
        } else {
            // Fallback to a default error image
            imageView.image = UIImage(systemName: "exclamationmark.triangle")
        }

        // Show retry button only for certain error types
        retryButton.isHidden = shouldHideRetryButton(for: error)
    }

    private func shouldHideRetryButton(for error: NetworkError) -> Bool {
        switch error {
        case .invalidURL, .decodingError, .unknown:
            return true // These errors are unlikely to be fixed by retrying
        case .networkError, .serverError, .invalidResponse:
            return false // These errors might be transient
        }
    }

    // MARK: - Actions
    @objc private func retryButtonTapped() {
        delegate?.errorViewDidTapRetry(self)
    }

    // MARK: - Animation
    public func show(in view: UIView, animated: Bool = true) {
        alpha = 0
        view.addSubview(self)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        } else {
            alpha = 1
        }
    }

    public func hide(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.alpha = 0
            } completion: { _ in
                self.removeFromSuperview()
            }
        } else {
            removeFromSuperview()
        }
    }
}
