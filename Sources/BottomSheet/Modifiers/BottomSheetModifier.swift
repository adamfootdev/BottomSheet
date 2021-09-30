//
//  BottomSheetModifier.swift
//  BottomSheet
//
//  Created by Adam Foot on 16/06/2021.
//

import SwiftUI

@available(iOS 15, *)
struct BottomSheet<T: Any, ContentView: View>: ViewModifier {
    @Binding private var isPresented: Bool
    
    private let detents: [UISheetPresentationController.Detent]
    private let largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier?
    private let prefersGrabberVisible: Bool
    private let prefersScrollingExpandsWhenScrolledToEdge: Bool
    private let prefersEdgeAttachedInCompactHeight: Bool
    private let widthFollowsPreferredContentSizeWhenEdgeAttached: Bool
    private var onDismiss: (() -> Void)?
    private let contentView: ContentView
    
    @State private var bottomSheetViewController: BottomSheetViewController<ContentView>?

    init(
        isPresented: Binding<Bool>,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
        largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = nil,
        prefersGrabberVisible: Bool = false,
        prefersScrollingExpandsWhenScrolledToEdge: Bool = true,
        prefersEdgeAttachedInCompactHeight: Bool = false,
        widthFollowsPreferredContentSizeWhenEdgeAttached: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder contentView: () -> ContentView
    ) {
        _isPresented = isPresented
        self.detents = detents
        self.largestUndimmedDetentIdentifier = largestUndimmedDetentIdentifier
        self.prefersGrabberVisible = prefersGrabberVisible
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferredContentSizeWhenEdgeAttached
        self.contentView = contentView()
        self.onDismiss = onDismiss
    }
    
    init(
        item: Binding<T?>,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
        largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = nil,
        prefersGrabberVisible: Bool = false,
        prefersScrollingExpandsWhenScrolledToEdge: Bool = true,
        prefersEdgeAttachedInCompactHeight: Bool = false,
        widthFollowsPreferredContentSizeWhenEdgeAttached: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder contentView: () -> ContentView
     ) {
        self._isPresented = Binding<Bool>(get: {
            item.wrappedValue != nil
        }, set: { newValue in
            item.wrappedValue = nil
        })
        self.detents = detents
        self.largestUndimmedDetentIdentifier = largestUndimmedDetentIdentifier
        self.prefersGrabberVisible = prefersGrabberVisible
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferredContentSizeWhenEdgeAttached
        self.contentView = contentView()
     }

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented, perform: updatePresentation)
    }

    private func updatePresentation(_ isPresented: Bool) {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: {
            $0.activationState == .foregroundActive
        }) as? UIWindowScene else { return }

        guard let rootViewController = windowScene.keyWindow?.rootViewController?.presentedViewController
            ?? windowScene.keyWindow?.rootViewController
        else { return }

        if isPresented {
            bottomSheetViewController = BottomSheetViewController(
                isPresented: $isPresented,
                detents: detents,
                largestUndimmedDetentIdentifier: largestUndimmedDetentIdentifier,
                prefersGrabberVisible: prefersGrabberVisible,
                prefersScrollingExpandsWhenScrolledToEdge: prefersScrollingExpandsWhenScrolledToEdge,
                prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight,
                widthFollowsPreferredContentSizeWhenEdgeAttached: widthFollowsPreferredContentSizeWhenEdgeAttached,
                content: contentView
            )

            rootViewController.present(bottomSheetViewController!, animated: true)

        } else {
            onDismiss?()
            bottomSheetViewController?.dismiss(animated: true)
        }
    }
}

@available(iOS 15, *)
extension View {

    /// Presents a bottom sheet when the binding to a Boolean value you provide is true. The bottom sheet
    /// can also be customised in the same way as a UISheetPresentationController can be.
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether to present the sheet that you create in the modifier’s content closure.
    ///   - detents: An array containing all of the possible sizes for the sheet. This array must contain at least one element. When you set this value, specify detents in order from smallest to largest height.
    ///   - largestUndimmedDetentIdentifier: The largest detent that doesn't dim the view underneath the sheet.
    ///   - prefersGrabberVisible: A Boolean value that determines whether the sheet shows a grabber at the top.
    ///   - prefersScrollingExpandsWhenScrolledToEdge: A Boolean value that determines whether scrolling expands the sheet to a larger detent.
    ///   - prefersEdgeAttachedInCompactHeight: A Boolean value that determines whether the sheet attaches to the bottom edge of the screen in a compact-height size class.
    ///   - widthFollowsPreferredContentSizeWhenEdgeAttached: A Boolean value that determines whether the sheet's width matches its view controller's preferred content size.
    ///   - onDismiss: The closure to execute when dismissing the sheet.
    ///   - contentView: A closure that returns the content of the sheet.
    public func bottomSheet<ContentView: View>(
        isPresented: Binding<Bool>,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
        largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = nil,
        prefersGrabberVisible: Bool = false,
        prefersScrollingExpandsWhenScrolledToEdge: Bool = true,
        prefersEdgeAttachedInCompactHeight: Bool = false,
        widthFollowsPreferredContentSizeWhenEdgeAttached: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder contentView: () -> ContentView
    ) -> some View {
        self.modifier(
            BottomSheet<Any, ContentView>(
                isPresented: isPresented,
                detents: detents,
                largestUndimmedDetentIdentifier:  largestUndimmedDetentIdentifier, prefersGrabberVisible: prefersGrabberVisible,
                prefersScrollingExpandsWhenScrolledToEdge: prefersScrollingExpandsWhenScrolledToEdge,
                prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight,
                widthFollowsPreferredContentSizeWhenEdgeAttached: widthFollowsPreferredContentSizeWhenEdgeAttached,
                onDismiss: onDismiss,
                contentView: contentView
            )
        )
    }
    
    /// Presents a bottom sheet when the binding to an Optinal item you pass to it is not nil. The bottom sheet
    /// can also be customised in the same way as a UISheetPresentationController can be.
    /// - Parameters:
    ///   - item: A binding to an Optional item that determines whether to present the sheet that you create in the modifier’s content closure.
    ///   - detents: An array containing all of the possible sizes for the sheet. This array must contain at least one element. When you set this value, specify detents in order from smallest to largest height.
    ///   - largestUndimmedDetentIdentifier: The largest detent that doesn't dim the view underneath the sheet.
    ///   - prefersGrabberVisible: A Boolean value that determines whether the sheet shows a grabber at the top.
    ///   - prefersScrollingExpandsWhenScrolledToEdge: A Boolean value that determines whether scrolling expands the sheet to a larger detent.
    ///   - prefersEdgeAttachedInCompactHeight: A Boolean value that determines whether the sheet attaches to the bottom edge of the screen in a compact-height size class.
    ///   - widthFollowsPreferredContentSizeWhenEdgeAttached: A Boolean value that determines whether the sheet's width matches its view controller's preferred content size.
    ///   - onDismiss: The closure to execute when dismissing the sheet.
    ///   - contentView: A closure that returns the content of the sheet.
    public func bottomSheet<T: Any, ContentView: View>(
        item: Binding<T?>,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
        largestUndimmedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = nil,
        prefersGrabberVisible: Bool = false,
        prefersScrollingExpandsWhenScrolledToEdge: Bool = true,
        prefersEdgeAttachedInCompactHeight: Bool = false,
        widthFollowsPreferredContentSizeWhenEdgeAttached: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder contentView: () -> ContentView
    ) -> some View {
        self.modifier(
            BottomSheet(
                item: item,
                detents: detents,
                largestUndimmedDetentIdentifier:  largestUndimmedDetentIdentifier, prefersGrabberVisible: prefersGrabberVisible,
                prefersScrollingExpandsWhenScrolledToEdge: prefersScrollingExpandsWhenScrolledToEdge,
                prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight,
                widthFollowsPreferredContentSizeWhenEdgeAttached: widthFollowsPreferredContentSizeWhenEdgeAttached,
                onDismiss: onDismiss,
                contentView: contentView
            )
        )
    }
}

