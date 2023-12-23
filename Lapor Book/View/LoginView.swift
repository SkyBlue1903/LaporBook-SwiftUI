//
//  LoginView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 23/12/23.
//

import SwiftUI

@MainActor final class LoginViewModel: ObservableObject {
  @Published var email: String = ""
  @Published var pass: String = ""
  @Published var error: String = ":"
  
  func signIn(email: String, pass: String) async throws {
    try await AuthManager.instance.signInUser(email: email, password: pass)
  }
}

struct LoginView: View {
  @StateObject private var viewModel = LoginViewModel()
  @State private var isAlert: Bool = false
  @EnvironmentObject var router: Router
  
    var body: some View {
      NavigationStack {
        ScrollView(.vertical, content: {
          VStack(alignment: .leading, spacing:10) {
            Text("Login to your existing account")
              .font(.subheadline)
              .foregroundStyle(.gray)
              .padding(.bottom, 30)
            CustomTextFieldView(fieldBinding: $viewModel.email, fieldName: "Email")
            CustomTextFieldView(fieldBinding: $viewModel.pass, fieldName: "Kata Sandi", isPassword: true)
            Button(action: {
              Task {
                do {
                  try await viewModel.signIn(email: viewModel.email, pass: viewModel.pass)
                  withAnimation {
                    router.currentPage = .dashboard
                  }
                } catch {
                  print("Error login:", error.localizedDescription)
                  viewModel.error = error.localizedDescription
                  isAlert.toggle()
                }
              }
            }, label: {
              CustomButtonView(name: "Login")
            })
            NavigationLink(destination: RegisterView()) {
              Text("Don't have an account? **Register**")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)
            }
          }
          .padding(.horizontal)
          .frame(maxWidth: .infinity)
        })
        .alert(isPresented: $isAlert) {
          Alert(title: Text("Error"), message: Text(viewModel.error), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("Login")
      }
    }
}

#Preview {
    LoginView()
}
