//
//  AddCommentView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 31/12/23.
//

import SwiftUI
struct AddComentView: View {
    @StateObject private var viewModel = ReportDetailViewModel()
  @State private var comment: String = ""
  @Binding var detent: Bool
  var reportId: String
  var body: some View {
    NavigationStack {
      VStack {
        CustomTextFieldView(fieldBinding: $viewModel.comment, fieldName: "")
        Spacer()
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Tambah") {
            Task {
              do {
                try await viewModel.addComm(reportId: self.reportId)
                self.detent = false
              }
            }
          }
        }
        ToolbarItem(placement: .topBarLeading) {
          Button("Batal") {
            self.detent = false
          }
        }
      }
      .interactiveDismissDisabled()
      .padding(.horizontal)
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Tambah Komentar")
    }
  }
}

#Preview {
  AddComentView(detent: .constant(true), reportId: "")
}
