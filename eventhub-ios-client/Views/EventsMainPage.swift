//
//  EventsMainPage.swift
//  eventhub-ios-client
//

import SwiftUI

struct EventsMainPage: View {
    @ObservedObject var viewModel: EventsViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showCreateEvent = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.38, blue: 0.0).opacity(0.18),
                    Color(red: 1.0, green: 0.65, blue: 0.0).opacity(0.12),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                Picker("Раздел", selection: $viewModel.eventsMainTab) {
                    ForEach(EventsMainTab.allCases) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if viewModel.eventsMainTab == .events {
                    Picker("Категория", selection: $viewModel.eventsListCategory) {
                        ForEach(EventsListCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }

                content
            }
            .padding(.top, 12)

            if viewModel.eventsMainTab == .events && viewModel.eventsListCategory == .drafts {
                Button {
                    showCreateEvent = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.38, blue: 0.0),
                                    Color(red: 1.0, green: 0.65, blue: 0.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                }
                .padding(24)
            }
        }
        .navigationTitle("Мероприятия")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.events.isEmpty {
                viewModel.loadEvents()
            }
        }
        .sheet(isPresented: $showCreateEvent) {
            NavigationView {
                EventCreationPage(viewModel: viewModel)
                    .environmentObject(authViewModel)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.events.isEmpty {
            Spacer()
            ProgressView()
            Spacer()
        } else {
            let events = viewModel.eventsForCurrentEventsScreen(currentUserId: authViewModel.currentUserId)

            if events.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: viewModel.eventsMainTab == .events ? "calendar.badge.plus" : "ticket")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text(emptyStateText)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(events) { event in
                            NavigationLink(destination: EventPage(event: event)) {
                                TinyEventCard(event: event)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 96)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.top, 4)
            }
        }
    }

    private var emptyStateText: String {
        switch viewModel.eventsMainTab {
        case .visits:
            return "Нет мероприятий для посещения"
        case .events:
            return "Нет мероприятий в этом разделе"
        }
    }
}
