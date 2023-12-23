//
//  AddReportView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 23/12/23.
//

import SwiftUI

struct AddReportView: View {
  @Binding var isPresented: Bool
  @State private var judul: String = ""
  @State private var deskripsi: String = ""
  @State private var selected: String = "Jalanan"
  
  @FocusState var descFocus: Bool
  
  var instances: [String] = ["Jalanan", "Pembangunan", "Revitalisasi", "Renovasi"]
    var body: some View {
      NavigationStack {
        ScrollView(.vertical, content: {
          VStack(spacing: 16) {
            CustomTextFieldView(fieldBinding: $judul, fieldName: "Judul Laporan")
            
            VStack(alignment: .leading) {
              Text("Foto Pendukung")
                .fontWeight(.bold)
              Spacer()
              ZStack {
                
              }
              .frame(maxWidth: .infinity)
              .frame(height: 200)
              .overlay(
                RoundedRectangle(cornerRadius: 14)
                  .stroke(descFocus ? Color(hex: LB.AppColors.textFieldFocused) : .gray, lineWidth: 2)
                  .opacity(descFocus ? 1 : 0.5)
              )
            }
            
            VStack(alignment: .leading) {
              Text("Instansi")
                .fontWeight(.bold)
              Picker("Selected Instance", selection: $selected) {
                ForEach(instances, id: \.self) { each in
                  Text(each)
                }
              }
              .frame(maxWidth: .infinity)
              .pickerStyle(.wheel)
              .overlay(
                RoundedRectangle(cornerRadius: 14)
                  .stroke(descFocus ? Color(hex: LB.AppColors.textFieldFocused) : .gray, lineWidth: 2)
                  .opacity(descFocus ? 1 : 0.5)
              )
            }
            
            VStack(alignment: .leading) {
              Text("Deskripsi Laporan")
                .fontWeight(.bold)
              TextField("Deskripsikan laporan Anda di sini...", text: $deskripsi, axis: .vertical)
                .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                .padding()
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .overlay(
                  RoundedRectangle(cornerRadius: 14)
                    .stroke(descFocus ? Color(hex: LB.AppColors.textFieldFocused) : .gray, lineWidth: 2)
                    .opacity(descFocus ? 1 : 0.5)
                )
                .focused($descFocus)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal)
        })
        .navigationTitle("Tambah Laporan")
      }
    }
}

#Preview {
  AddReportView(isPresented: .constant(true))
}
