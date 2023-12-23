//
//  DashboardView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 23/12/23.
//

import SwiftUI

struct DashboardView: View {
  @EnvironmentObject private var router: Router
    var body: some View {
      NavigationStack {
        ScrollView(.vertical) {
          VStack(alignment: .leading) {
            Text("Erlangga")
              .font(.title)
            Text("Admin")
              .font(.headline)
            Divider()
            Text(verbatim: "angga1433@gmail.com")
            Text("081234563505")
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
        .navigationTitle("Profile")
      }
    }
}

#Preview {
  NavigationStack {
    DashboardView()
  }
}
