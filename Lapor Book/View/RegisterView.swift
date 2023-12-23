//
//  RegisterView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 22/12/23.
//

import SwiftUI

@MainActor
final class RegisteViewModel: ObservableObject {
  @Published var nama: String = ""
  @Published var email: String = ""
  @Published var noHp: String = ""
  @Published var pass: String = ""
  @Published var confirmPass: String = ""
  @Published var error: String = ""
  
  func registerUser() async throws {
    try await AuthManager.instance.createUser(email: email, password: pass, fullname: nama, phone: noHp)
  }
}

struct RegisterView: View {
  @StateObject private var viewModel = RegisteViewModel()
  @State private var isAlert: Bool = false
  @EnvironmentObject private var router: Router
  
  var body: some View {
    NavigationStack {
      ScrollView(.vertical, content: {
        VStack(alignment: .leading, spacing:10) {
          Text("Create your profile to start your journey")
            .font(.subheadline)
            .foregroundStyle(.gray)
            .padding(.bottom, 30)
          CustomTextFieldView(fieldBinding: $viewModel.nama, fieldName: "Nama")
          CustomTextFieldView(fieldBinding: $viewModel.email, fieldName: "Email")
          CustomTextFieldView(fieldBinding: $viewModel.noHp, fieldName: "No. Handphone")
          CustomTextFieldView(fieldBinding: $viewModel.pass, fieldName: "Kata Sandi", isPassword: true)
          CustomTextFieldView(fieldBinding: $viewModel.confirmPass, fieldName: "Konfirmasi Kata Sandi", isPassword: true)
          Button(action: {
            Task {
              do {
                try await viewModel.registerUser()
                withAnimation {
                  self.router.currentPage = .dashboard
                }
              } catch {
                print("Error creating user:", error.localizedDescription)
                viewModel.error = error.localizedDescription
                self.isAlert.toggle()
              }
            }
          }, label: {
            CustomButtonView(name: "Register")
          })
          Text("Already have an account? **Login**")
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
      })
      .alert(isPresented: $isAlert) {
        Alert(title: Text("Error"), message: Text(viewModel.error), dismissButton: .default(Text("OK")))
      }
      .navigationTitle("Register")
    }
  }
}

#Preview {
  RegisterView()
}
