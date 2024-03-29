//
//  MyReportView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 23/12/23.
//

import SwiftUI

@MainActor
final class MyReportViewModel: ObservableObject {
  @Published var data: [ReportModel] = []
  @Published var userId: String = ""
  
  func loadReports() async throws {
    self.data = try await ReportManager.instance.loadAllReports(byId: self.userId)
  }
}

struct MyReportView: View {
  @Environment(\.colorScheme) var colorScheme
  @State private var addReportSheet: Bool = false
  @StateObject private var viewModel = MyReportViewModel()
  
  let columnSize: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
  var body: some View {
    if addReportSheet {
      Task {
        do {
          try await viewModel.loadReports()
        }
      }
    }
    return AnyView(
      NavigationStack {
        ScrollView(.vertical){
          LazyVGrid(columns: columnSize) {
            ForEach(viewModel.data, id: \.self) { each in
              NavigationLink(destination: ReportDetailView(data: each)) {
                ReportCard2View(data: each)
              }
            }
          }
          .padding(.horizontal)
        }
        .toolbar(content: {
          ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
              self.addReportSheet.toggle()
            }) {
              Image(systemName: "plus")
            }
          }
        })
        .sheet(isPresented: $addReportSheet, content: {
          AddReportView(isPresented: $addReportSheet)
        })
        .onAppear(perform: {
          Task {
            do {
              viewModel.userId = try AuthManager.instance.getAuthUser().uid
              try await viewModel.loadReports()
            } catch {
              print("Error fetching all data when view appear:", error.localizedDescription)
            }
          }
        })
        .navigationTitle("Laporan Saya")
      }
    )
  }
}

#Preview {
  MyReportView()
}
