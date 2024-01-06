//
//  ReportCardView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 24/12/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReportCard1View: View {
  @Environment(\.colorScheme) var colorScheme
  
  var body: some View {
    ZStack {
      Color.gray.opacity(colorScheme == .light ? 0.15 : 0.2)
      VStack(alignment: .leading, spacing: 0) {
        Rectangle()
          .frame(height: UIScreen.main.bounds.height * 0.25)
        Text("Judul Laporan")
          .lineLimit(1)
          .frame(height: UIScreen.main.bounds.height * 0.075)
          .padding(.horizontal, 8)
        HStack(spacing: 0) {
          Text("Hello")
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.06)
            .background(.blue)
            .lineLimit(1)
          Text("12/12/2023")
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.06)
            .background(.accent)
            .lineLimit(1)
        }
      }
    }
    .frame(maxWidth: .infinity)
    .cornerRadius(10)
    .padding(.bottom, 0)
  }
}

#Preview {
  ReportCard1View()
}

// MARK: - Report Card Design 2
struct ReportCard2View: View {
  @Environment(\.colorScheme) var colorScheme
  @State private var like = [LikeModel]()
  var data: ReportModel?
  
  var body: some View {
    ZStack {
      Color(hex: colorScheme == .light ? LB.AppColors.cardBgLight : LB.AppColors.cardBgDark)
      VStack(alignment: .leading, spacing: 0) {
        WebImage(url: URL(string: data?.imgPath ?? ""))
          .resizable()
          .placeholder(content: {
            ProgressView()
              .font(.title)
              .aspectRatio(contentMode: .fill)
              .frame(height: UIScreen.main.bounds.height * 0.2)
              .frame(maxWidth: .infinity)
              .clipped()
          })
          .onFailure(perform: { _ in
            VStack(spacing: 16) {
              Image(systemName: "wifi.slash")
                .font(.largeTitle)
              Text("Gagal mengunduh")
            }
          })
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(height: UIScreen.main.bounds.height * 0.2)
          .clipped()
        VStack(alignment: .leading, spacing: 0) {
          Text("\(formatDate(data?.date ?? Date()))")
            .font(.system(size: 12, weight: .regular, design: .default))
            .foregroundStyle(Color.gray)
            .lineLimit(1)
            .padding(.bottom, 8)
          //          .frame(height: UIScreen.main.bounds.height * 0.075)
          
          Text("\(data?.title ?? "Loading...")")
            .foregroundStyle(colorScheme == .light ? .black : .white)
            .lineLimit(2)
            .font(.headline)
            .multilineTextAlignment(.leading)
          Spacer()
          HStack(spacing: 0) {
            Text(data?.status ?? "")
              .font(.system(size: 14, weight: .bold, design: .default))
              .foregroundStyle(.accent)
            Text(" (\(like.count) Like)")
              .font(.system(size: 14, weight: .bold, design: .default))
              .foregroundStyle(.accent)
          }
          
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
      }
    }
    .onAppear(perform: {
      Task {
        do {
          self.like = try await ReportManager.instance.loadAllLikes(reportId: data?.id ?? "")
        }
      }
    })
    .frame(maxWidth: .infinity)
    .cornerRadius(10)
//    .padding(.bottom, 0)
  }
  
  func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM yyyy"
    return dateFormatter.string(from: date)
  }
}

#Preview {
  ReportCard2View()
    .frame(height: 300)
}
