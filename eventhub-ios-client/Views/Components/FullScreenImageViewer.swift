//
//  FullScreenImageViewr.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.10.2025.
//

import SwiftUI

struct FullScreenImageViewer: View {
    let imageUrls: [String]
    @State private var currentIndex: Int
    var onDismiss: () -> Void

    init(imageUrls: [String], initialIndex: Int, onDismiss: @escaping () -> Void) {
        self.imageUrls = imageUrls
        self._currentIndex = State(initialValue: initialIndex)
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.85).ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(imageUrls.enumerated()), id: \.offset) { index, url in
                    ZoomableAsyncImage(urlString: url)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}

struct ZoomableAsyncImage: View {
    let urlString: String
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { image in
            image
                .resizable()
                .scaledToFit()
                .offset(offset)
                .scaleEffect(scale)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) { scale = max(1.0, scale) }
                            },
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) { offset = .zero }
                            }
                    )
                )
        } placeholder: {
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
