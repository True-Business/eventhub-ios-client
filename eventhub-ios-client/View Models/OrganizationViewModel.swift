//
//  OrganizationViewModel.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 17.10.2025.
//
import SwiftUI

func emptyOrganization() -> Organization {
    Organization(id: UUID(), name: "", coverUrl: "", description: "", address: "", admins: [], images: [], events: [])
}

class OrganizationViewModel: ObservableObject {
    enum OrganizationState {
        case loading
        case success(Organization)
        case error(String)
    }
   
    @Published var organizationState: OrganizationState = .loading
    @Published var currentOrganization: Organization = emptyOrganization()
    @Published var isMy: Bool = true
    
    private let repository = OrgRepository()
    private let tag = "ORGANIZATION_VIEW_MODEL"
    
    func setCurrentOrganization(_ organization: Organization) {
        currentOrganization = organization
        print("\(tag): current organization: \(organization.name)")
    }
    
    func fetchOrganizationFromRepo(orgId: UUID) {
        if let org = repository.fetchOrganizationMock(orgId: orgId) {
            organizationState = .success(org)
            currentOrganization = org
        } else {
            organizationState = .error("Organization not found")
        }
    }
    
    func updateOrganization(
        name: String = "",
        coverUrl: String = "",
        description: String = "",
        address: String = "",
        admins: [User] = [],
        images: [String] = [],
        events: [Event] = []
    ) {
        currentOrganization = Organization(
            id: currentOrganization.id,
            name: name,
            coverUrl: coverUrl,
            description: description,
            address: address,
            admins: admins,
            images: images,
            events: events
        )
    }
    
    func updateAdmins(_ newAdmins: [User]) {
        currentOrganization.admins = newAdmins
        print("\(tag): admins count: \(newAdmins.count)")
    }
}
