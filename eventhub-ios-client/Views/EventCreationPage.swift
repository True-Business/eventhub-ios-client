//
//  EventCreationPage.swift
//  eventhub-ios-client
//

import SwiftUI

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

    var body: some View {
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

            Section("Место и время") {
                TextField("Город", text: $city)
                TextField("Адрес", text: $address)
                TextField("Как добраться", text: $route)
                DatePicker("Начало", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                DatePicker("Окончание", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
            }

            Section("Настройки") {
                TextField("Цена", text: $price)
                    .keyboardType(.decimalPad)
                TextField("Лимит участников", text: $peopleLimit)
                    .keyboardType(.numberPad)
                Toggle("Нужна регистрация", isOn: $withRegister)
                Toggle("Открытое мероприятие", isOn: $isOpen)
            }

            Section {
                Button {
                    submit(status: .draft)
                } label: {
                    Label("Сохранить черновик", systemImage: "tray.and.arrow.down")
                }

                Button {
                    submit(status: .planned)
                } label: {
                    Label("Опубликовать", systemImage: "paperplane.fill")
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Создание мероприятия")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Закрыть") {
                    dismiss()
                }
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
    }

    private func submit(status: EventStatus) {
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
            organizerId: authViewModel.currentUserId
        ) { success in
            if success {
                dismiss()
            } else {
                showError = true
            }
        }
    }
}
