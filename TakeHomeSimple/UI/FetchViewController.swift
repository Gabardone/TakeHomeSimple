//
//  FetchViewController.swift
//  TakeHomeSimple
//
//  Created by Óscar Morales Vivó on 1/8/23.
//

import os
import UIKit
import SwiftUI

/**
 A simple view controller that manages display of a progress indicator during data load, or an error label if it
 ends with an error. If there's an error the view controller offers the opportunity to retry the fetch.

 If the data loads properly, the view controller places a different view controller as its content. After that this
 view controller should do nothing beyond containing its content.
 */
@MainActor
class FetchViewController: UIViewController {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "FetchViewController")

    typealias FetchOperation = @Sendable () async throws -> EmployeeList

    /**
     A fetch view controller basically runs a state machine for an initial data load. Once it ends successfully the
     data will be passed on to a content view controller and this will remain as a mere decoration around it.
     */
    enum LoadState {
        /// The view controller has not started running yet.
        case uninitialized

        /// Loading is in progress. The associated task is in charge of it.
        case loading(Task<Void, Never>)

        /// Loading has concluded with an error.
        case error(Error)

        /// Loading concluded successfully and fetched the associated content.
        case success(EmployeeList)

        /**
         The fetch view controller is done and doesn't want to hold on to any data anymore. The content view controller
         has taken it from here.
         */
        case done
    }

    /**
     The view controller is initialized with a fetch operation that it will start running immediately.

     The fetch operation is taken as a block so it can be re-run if there's an error and the user wants to retry.
     The block is also passed in to the content display view controller so it can be reused for data refresh.
     - Parameter fetchOperation: A block that asynchronously fetches the data.
     */
    init(fetchOperation: @escaping FetchOperation) {
        self.fetchOperation = fetchOperation
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let fetchOperation: FetchOperation

    /// Kept `internal` merely for testing purposes.
    var loadState: LoadState = .uninitialized {
        didSet {
            updateLoadingState(fromState: oldValue, toState: loadState)
        }
    }

    private var loadingContainer: UIView?

    private var errorDisplay: UIView?

    private var contentViewController: UIViewController?

    // MARK: - UIViewController Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        // What are the chances that we will _not_ want to load the data? let's start with it...
        refetch()
    }
}

// MARK: - Fetch Management

extension FetchViewController {
    private func updateLoadingState(fromState: LoadState, toState: LoadState) {
        // Can't declare `LoadState` equatable due to `Error` not complying with `Equatable`.
        switch (fromState, toState) {
        case (.loading, .error(let newError)):
            // Show up the error UI.
            setupErrorDisplay(error: newError)

        case (.loading, .success(let data)):
            // Everything is awesome, show the content and go dormant.
            setupContent(employeeList: data)
            loadState = .done

        case (.success, .done):
            // We're done, nothing more to do here.
            break

        case (.error, .loading), (.uninitialized, .loading):
            // We should see this flow happens when starting the first load or when the user retries after error.
            setupLoadingIndicator()

        default:
            let oldValueDescription = String(describing: fromState)
            let newValueDescription = String(describing: toState)
            Self.logger.error("Unexpected loading state transition for fetch view controller \(self).\n\(oldValueDescription) -> \(newValueDescription)")
        }
    }

    private func refetch() {
        if case .loading = loadState {
            // We're already on it, let's just go away.
            return
        }

        // If we're doing this we're loading.
        loadState = .loading(Task {
            do {
                let employeeList = try await fetchOperation()
                loadState = .success(employeeList)
            } catch {
                loadState = .error(error)
            }
        })
    }
}

// MARK: - UI Setup

extension FetchViewController {
    private func setupLoadingIndicator() {
        let loadingContainer = self.loadingContainer ?? {
            // A simple label + loading indicator will do.
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.startAnimating()
            let loadingLabel = UILabel()
            loadingLabel.text = "Loading…"
            let loadingContainer = UIStackView(arrangedSubviews: [loadingLabel, activityIndicator])
            loadingContainer.alignment = .center

            loadingContainer.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(loadingContainer)
            NSLayoutConstraint.activate([
                loadingContainer.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                loadingContainer.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
            ])

            self.loadingContainer = loadingContainer
            return loadingContainer
        }()

        loadingContainer.isHidden = false
        errorDisplay?.isHidden = true
        contentViewController?.view.isHidden = true
    }

    private func setupErrorDisplay(error: Error) {
        let errorDisplay = self.errorDisplay ?? {
            let errorLabel = UILabel()
            // TODO: Actually show error.localizedDescription instead of a generic message.
            errorLabel.text = "There was an error fetching the employee data."
            errorLabel.numberOfLines = 0
            errorLabel.lineBreakMode = .byWordWrapping

            let retryButton = UIButton(configuration: .plain())
            retryButton.configuration?.title = "Retry…"
            retryButton.addTarget(self, action: #selector(retry), for: .primaryActionTriggered)

            let errorDisplay = UIStackView(arrangedSubviews: [errorLabel, retryButton])
            errorDisplay.axis = .vertical
            errorDisplay.alignment = .center

            errorDisplay.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(errorDisplay)
            NSLayoutConstraint.activate([
                errorDisplay.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                errorDisplay.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: errorDisplay.trailingAnchor)
            ])

            self.errorDisplay = errorDisplay
            return errorDisplay
        }()

        errorDisplay.isHidden = false
        loadingContainer?.isHidden = true
        contentViewController?.view.isHidden = true
    }

    private func setupContent(employeeList: EmployeeList) {
        let contentViewController = contentViewController ?? {
            let contentViewController = UIViewController()

            let contentView = contentViewController.view!
            contentView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(contentView)
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])

            addChild(contentViewController)
            contentViewController.didMove(toParent: self)

            self.contentViewController = contentViewController
            return contentViewController
        }()

        contentViewController.view.isHidden = false
        loadingContainer?.isHidden = true
        errorDisplay?.isHidden = true
    }
}

// MARK: - Control Actions

extension FetchViewController {
    @objc
    private func retry() {
        refetch()
    }
}
