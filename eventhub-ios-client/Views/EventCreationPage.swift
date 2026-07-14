//
//  EventCreationPage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 12.07.2026.
//

import PhotosUI
import SwiftUI
import UIKit

struct EventCreationPage: View {
    @ObservedObject var viewModel: EventsViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var city = ""
    @State private var address = ""
    @State private var route = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    @State private var price = ""
    @State private var peopleLimit = ""
    @State private var withRegister = false
    @State private var isOpen = true
    @State private var category: EventCategory = .placeholder
    @State private var showError = false
    @State private var posterPickerItem: PhotosPickerItem?
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var posterImage: SelectedEventImage?
    @State private var photoImages: [SelectedEventImage] = []

    private let controlColor = Color.black

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.38, blue: 0.0),
                    Color(red: 1.0, green: 0.65, blue: 0.0),
                    Color(red: 1.0, green: 0.78, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Form {
                Section("Основное") {
                    TextField("Название мероприятия", text: $title)
                    TextField("Описание мероприятия", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    Picker("Категория", selection: $category) {
                        ForEach(EventCategory.allCases.filter { $0 != .all }) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                }
                .listRowBackground(Color(.systemBackground).opacity(0.9))

                Section("Изображения") {
                    PhotosPicker(selection: $posterPickerItem, matching: .images) {
                        Label(posterImage == nil ? "Выбрать постер" : "Заменить постер", systemImage: "photo")
                            .foregroundStyle(controlColor)
                    }
                    .tint(controlColor)

                    if let posterImage {
                        EventCreationImagePreview(image: posterImage.image, height: 180)
                    }

                    PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 8, matching: .images) {
                        Label(photoImages.isEmpty ? "Выбрать фотографии" : "Изменить фотографии", systemImage: "photo.on.rectangle")
                            .foregroundStyle(controlColor)
                    }
                    .tint(controlColor)

                    if !photoImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(photoImages) { photo in
                                    Image(uiImage: photo.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 92, height: 92)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listRowBackground(Color(.systemBackground).opacity(0.9))

                Section("Место и время") {
                    TextField("Город", text: $city)
                    TextField("Адрес", text: $address)
                    TextField("Как добраться", text: $route)
                    DatePicker("Начало", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Окончание", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                }
                .listRowBackground(Color(.systemBackground).opacity(0.9))

                Section("Настройки") {
                    TextField("Цена", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Лимит участников", text: $peopleLimit)
                        .keyboardType(.numberPad)
                    Toggle("Нужна регистрация", isOn: $withRegister)
                    Toggle("Открытое мероприятие", isOn: $isOpen)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.9))

                Section {
                    Button {
                        submit(status: .draft)
                    } label: {
                        Label("Сохранить черновик", systemImage: "tray.and.arrow.down")
                            .foregroundStyle(controlColor)
                    }
                    .tint(controlColor)

                    Button {
                        submit(status: .planned)
                    } label: {
                        Label("Опубликовать", systemImage: "paperplane.fill")
                            .foregroundStyle(controlColor)
                    }
                    .tint(controlColor)
                    .disabled(viewModel.isLoading)
                }
                .listRowBackground(Color(.systemBackground).opacity(0.9))
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Создание мероприятия")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Закрыть") {
                    dismiss()
                }
                .tint(controlColor)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8)
            }
        }
        .alert("Ошибка", isPresented: $showError) {
            Button("Ок", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Не удалось создать мероприятие")
        }
        .onChange(of: posterPickerItem) { _, newItem in
            loadPoster(from: newItem)
        }
        .onChange(of: photoPickerItems) { _, newItems in
            loadPhotos(from: newItems)
        }
    }

    private func submit(status: EventStatus) {
        let uploads = makeImageUploads()

        viewModel.createEvent(
            title: title,
            description: description,
            city: city,
            address: address,
            route: route,
            startDate: startDate,
            endDate: endDate,
            price: Double(price.replacingOccurrences(of: ",", with: ".")),
            peopleLimit: Int(peopleLimit),
            withRegister: withRegister,
            isOpen: isOpen,
            category: category,
            status: status,
            organizerId: authViewModel.currentUserId,
            imageUploads: uploads
        ) { success in
            if success {
                dismiss()
            } else {
                showError = true
            }
        }
    }

    private func loadPoster(from item: PhotosPickerItem?) {
        guard let item else {
            posterImage = nil
            return
        }

        Task {
            posterImage = await loadSelectedImage(from: item)
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) {
        Task {
            var loadedImages: [SelectedEventImage] = []

            for item in items {
                if let image = await loadSelectedImage(from: item) {
                    loadedImages.append(image)
                }
            }

            photoImages = loadedImages
        }
    }

    private func loadSelectedImage(from item: PhotosPickerItem) async -> SelectedEventImage? {
        do {
            guard
                let data = try await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else {
                return nil
            }

            let uploadData = image.jpegData(compressionQuality: 0.86) ?? data
            return SelectedEventImage(data: uploadData, image: image)
        } catch {
            await MainActor.run {
                viewModel.errorMessage = error.localizedDescription
                showError = true
            }
            return nil
        }
    }

    private func makeImageUploads() -> [EventImageUpload] {
        var uploads: [EventImageUpload] = []

        if let posterImage {
            uploads.append(EventImageUpload(originName: "poster.jpg", data: posterImage.data))
        }

        uploads.append(
            contentsOf: photoImages.enumerated().map { index, photo in
                EventImageUpload(originName: "photo-\(index + 1).jpg", data: photo.data)
            }
        )

        return uploads
    }
}

private struct SelectedEventImage: Identifiable {
    let id = UUID()
    let data: Data
    let image: UIImage
}

private struct EventCreationImagePreview: View {
    let image: UIImage
    let height: CGFloat

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
