//
//  OrganizationProfilePage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 13.10.2025.
//

import SwiftUI

struct OrganizationProfilePage: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: OrganizationViewModel

    @State private var isEditing = false
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var address: String = ""

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    TopImageBlock(
                        imageUrl: viewModel.currentOrganization.coverUrl,
                        name: $name,
                        isEditing: isEditing
                    )
                    
                    ContentBody(
                        description: $description,
                        address: $address,
                        images: $viewModel.currentOrganization.images,
                        events: $viewModel.currentOrganization.events,
                        admins: $viewModel.currentOrganization.admins,
                        isEditing: isEditing
                    )
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(isEditing ? "Редактирование" : "")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isMy {
                    if isEditing {
                        Button(action: {
                            viewModel.updateOrganization(
                                name: name,
                                description: description,
                                address: address
                            )
                            isEditing = false
                        }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black)
                        }
                    } else {
                        Button(action: { isEditing = true }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
        .onAppear {
            let org = viewModel.currentOrganization
            name = org.name
            description = org.description
            address = org.address
        }
    }
}

struct TopImageBlock: View {
    let imageUrl: String
    @Binding var name: String
    let isEditing: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 280)
            }

            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)

            if isEditing {
                TextField("Название", text: $name)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            } else {
                Text(name)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            }
        }
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

struct ContentBody: View {
    @Binding var description: String
    @Binding var address: String
    @Binding var images: [String]
    @Binding var events: [Event]
    @Binding var admins: [User]

    let isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            LocationBlock(address: $address, isEditing: isEditing) { newVal in
                address = newVal
            }
            DescriptionBlock(description: $description, isEditing: isEditing) { newVal in
                description = newVal
            }
            EventsBlock(events: events, isEditing: isEditing, onLock: { _ in })
            PicturesBlock(images: $images, onDeleteImage: { _ in }, isEditing: isEditing)
        }
        .padding(.horizontal)
    }
}

struct LocationBlock: View {
    @Binding var address: String
    var isEditing: Bool
    var onAddressChange: (String) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "mappin.and.ellipse")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.black)

            if isEditing {
                TextField(
                    "Введите адрес",
                    text: $address,
                    onEditingChanged: { _ in },
                    onCommit: {}
                )
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .underline()
                .onChange(of: address, perform: onAddressChange)
                .padding(.trailing, 12)
            } else {
                Text(address)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .underline()
            }
        }
        .padding(.horizontal, 12)
    }
}

struct DescriptionBlock: View {
    @Binding var description: String
    var isEditing: Bool
    var onDescriptionChange: (String) -> Void

    var body: some View {
        ZStack {
            // Аналог Surface
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 223/255, green: 223/255, blue: 223/255).opacity(0.51))
                .shadow(radius: 4)
        }
        .overlay(
            VStack(alignment: .leading, spacing: 8) {
                Text("Описание")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.secondary)

                if isEditing {
                    TextEditor(text: $description)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(minHeight: 120)
                        .padding(.horizontal, 8)
                        .onChange(of: description, perform: onDescriptionChange)
                } else {
                    Text(description)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(nil)
                        .padding(.horizontal, 8)
                }
            }
            .padding(12)
        )
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding(12)
    }
}

struct EventsBlock: View {
    let events: [Event]
    var isEditing: Bool
    var onLock: (Event) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Мероприятия")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(events, id: \.title) { event in
                        TinyEventCard(
                            event: event,
                            withLabels: true,
                            isEditing: isEditing,
                            onLockClick: { onLock(event) }
                        )
                    }
                }
                .padding(.horizontal, 12)
            }
        }
    }
}

struct PicturesBlock: View {
    @State private var showFullScreenViewer = false
    @State private var selectedImageIndex = 0

    @Binding var images: [String]
    var onDeleteImage: (Int) -> Void
    var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Изображения")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 36)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, url in
                        ZStack {
                            ImageCard(
                                imageUrl: url,
                                onClick: {
                                    selectedImageIndex = index
                                    showFullScreenViewer = true
                                }
                            )
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(radius: 4)

                            if isEditing {
                                Color.black.opacity(0.6)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .overlay(
                                        Button(action: { onDeleteImage(index) }) {
                                            Image(systemName: "trash")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.accentColor)
                                                .padding()
                                        }
                                        .frame(width: 95, height: 65)
                                        .background(Color.black.opacity(0.8))
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                    )
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.3), value: isEditing)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
            }

            // Полноэкранный просмотр изображений
            if showFullScreenViewer {
                FullScreenImageViewer(
                    imageUrls: images,
                    initialIndex: selectedImageIndex,
                    onDismiss: { showFullScreenViewer = false }
                )
            }
        }
    }
}

struct ImageCard: View {
    let imageUrl: String
    var onClick: () -> Void = {}

    var body: some View {
        Button(action: onClick) {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 320, height: 200)
                    .clipped()
            } placeholder: {
                Color.gray.opacity(0.3)
                    .frame(width: 320, height: 200)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.white)
        .cornerRadius(18)
        .shadow(radius: 2)
    }
}
