//
//  DashboardView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 23/12/23.
//

import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
  @Published var fullname: String = ""
  @Published var email: String = ""
  @Published var phone: String = ""
  @Published var role: String = ""
  
  func fetchData() async throws {
    let auth = try AuthManager.instance.getAuthUser()
    let result = try await AuthManager.instance.getFSUser(user: auth)
    self.email = result.email ?? "Loading..."
    self.fullname = result.fullname ?? "Loading..."
    self.phone = result.phone ?? ""
    self.role = result.role ?? ""
  }
}

struct DashboardView: View {
  @EnvironmentObject private var router: Router
  @StateObject private var viewModel = DashboardViewModel()
  
    var body: some View {
      NavigationStack {
        ScrollView(.vertical) {
          VStack(alignment: .leading) {
            Text("\(viewModel.fullname)")
              .font(.title)
            Text("\(viewModel.role)")
              .font(.headline)
            Divider()
            Text(verbatim: "\(viewModel.email)")
            Text("\(viewModel.phone)")
            Button(action: {
              Task {
                do {
                  try AuthManager.instance.logoutUser()
                  withAnimation {
                    self.router.currentPage = .login
                  }
                }
              }
            }, label: {
              CustomButtonView(name: "Logout")
            })
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal)
        }
        .onAppear(perform: {
          Task {
            do {
              try await viewModel.fetchData()
            }
          }
        })
        .navigationTitle("Profile")
      }
    }
}

#Preview {
  NavigationStack {
    DashboardView()
  }
}
