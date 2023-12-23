//
//  ContentView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 22/12/23.
//

import SwiftUI

enum Page {
  case launchScreen, dashboard, login
}

class Router: ObservableObject {
  @Published var currentPage: Page = .launchScreen
}

struct ViewController: View {
  @EnvironmentObject var router: Router
  @State private var showLoginView: Bool = false
  
  var body: some View {
    switch router.currentPage {
    case .launchScreen:
      VStack {
        Text("Aplikasi Lapor Book")
          .font(.title)
        ProgressView()
          .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
              withAnimation {
                let auth = try? AuthManager.instance.getAuthUser()
                if (auth != nil) {
                  self.router.currentPage = .dashboard
                } else {
                  self.router.currentPage = .login
                }
              }
            }
          })
      }
      .padding()
    case .dashboard:
      TabView {
        Text("Coming soon...")
          .tabItem {
            Label("Semua Laporan", systemImage: "circle.grid.2x2.fill")
          }
        Text("Coming soon... (2)")
          .tabItem {
            Label("Laporan Saya", systemImage: "book.fill")
          }
        DashboardView()
          .tabItem {
            Label("Profile", systemImage: "person.fill")
          }
      }
      .transition(.move(edge: .trailing)) // Slide from right animation
    case .login:
      LoginView()
        .transition(.move(edge: .leading)) // Slide from left animation
    }
  }
}



#Preview {
  ViewController()
    .environmentObject(Router())
}
