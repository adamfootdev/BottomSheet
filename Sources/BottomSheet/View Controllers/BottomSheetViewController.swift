//
//  BottomSheetViewController.swift
//  BottomSheet
//
//  Created by Adam Foot on 16/06/2021.
//

import UIKit
import SwiftUI
import Combine

@available(iOS 15, *)
class BottomSheetViewController<Content: View>: UIViewController, UISheetPresentationControllerDelegate {
    @Binding private var isPresented: Bool

    private let detents: [UISheetPresentationController.Detent]
    private let largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    private let prefersGrabberVisible: Bool
    private let prefersScrollingExpandsWhenScrolledToEdge: Bool
    private let prefersEdgeAttachedInCompactHeight: Bool
    private let widthFollowsPreferredContentSizeWhenEdgeAttached: Bool

    private let contentView: UIHostingController<Content>

    init(
        isPresented: Binding<Bool>,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
        largestUndimmedDetentIdentifier:  UISheetPresentationController.Detent.Identifier? = nil,
        prefersGrabberVisible: Bool = false,
        prefersScrollingExpandsWhenScrolledToEdge: Bool = true,
        prefersEdgeAttachedInCompactHeight: Bool = false,
        widthFollowsPreferredContentSizeWhenEdgeAttached: Bool = false,
        isModalInPresentation: Bool = false,
        content: Content
    ) {
        _isPresented = isPresented

        self.detents = detents
        self.largestUndimmedDetentIdentifier = largestUndimmedDetentIdentifier
        self.prefersGrabberVisible = prefersGrabberVisible
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferredContentSizeWhenEdgeAttached
        
        self.contentView = UIHostingController(rootView: content)

        super.init(nibName: nil, bundle: nil)
        self.isModalInPresentation = isModalInPresentation
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(contentView)
        view.addSubview(contentView.view)

        contentView.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = detents
            presentationController.largestUndimmedDetentIdentifier = largestUndimmedDetentIdentifier
            presentationController.prefersGrabberVisible = prefersGrabberVisible
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
            presentationController.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
            presentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferredContentSizeWhenEdgeAttached
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        isPresented = false
    }
}
