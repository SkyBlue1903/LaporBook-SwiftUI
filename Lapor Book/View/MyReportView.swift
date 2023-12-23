//
//  MyReportView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 23/12/23.
//

import SwiftUI

struct MyReportView: View {
  @Environment(\.colorScheme) var colorScheme
  @State private var addReportSheet: Bool = false
  
  let columnSize: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    var body: some View {
      NavigationStack {
        ScrollView(.vertical){
          LazyVGrid(columns: columnSize) {
            ForEach(1..<6) { each in
              ZStack {
                Color.gray.opacity(colorScheme == .light ? 0.15 : 0.5)
                VStack(spacing: 0) {
                  Rectangle()
                    .frame(height: 150)
                  Group {
                    Text("Judul Laporan")
                      .lineLimit(1)
                    HStack {
                      Text("Process")
                      Spacer()
                      Text("12/12/2023")
                    }
                  }
                  .padding()
                }
              }
                .frame(maxWidth: .infinity)
//                .frame(height: 250)
                .cornerRadius(10)
                .padding(.bottom, 8)
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
        .navigationTitle("Laporan Saya")
      }
    }
}

#Preview {
    MyReportView()
}
