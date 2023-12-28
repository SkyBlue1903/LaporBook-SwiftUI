//
//  Templates.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 22/12/23.
//

import SwiftUI

// MARK: - Custom Text Field with Text and Placeholder
struct CustomTextFieldView: View {
  @Binding var fieldBinding: String
  @FocusState var focus: Bool
  //  @Binding var focus: Bool
  @State var fieldName: String
  @State var isPassword: Bool = false
  @State private var isPasswordShown: Bool = false
  var keyboardType: UIKeyboardType = .default
  
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(fieldName)
        .fontWeight(.bold)
      if !isPassword {
        if fieldName == "Email" {
          TextField(fieldName, text: $fieldBinding)
            .padding()
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .frame(height: 45)
            .keyboardType(.emailAddress)
            .overlay(
              RoundedRectangle(cornerRadius: 14)
                .stroke(focus ? Color(hex: LB.AppColors.textFieldFocused) : .gray, lineWidth: 2)
                .opacity(focus ? 1 : 0.5)
            )
            .focused($focus)
        } else {
          TextField(fieldName, text: $fieldBinding)
            .padding()
            .autocorrectionDisabled()
            .frame(height: 45)
            .keyboardType(keyboardType)
            .overlay(
              RoundedRectangle(cornerRadius: 14)
                .stroke(focus ? Color(hex: LB.AppColors.textFieldFocused) : .gray, lineWidth: 2)
                .opacity(focus ? 1 : 0.5)
            )
            .textInputAutocapitalization(.words)
            .focused($focus)
        }
      } else {
        HStack {
          if isPasswordShown {
            TextField(fieldName, text: $fieldBinding)
              .focused($focus)
          } else {
            SecureField(fieldName, text: $fieldBinding)
              .focused($focus)
          }
          Spacer()
          Button(action: {
            isPasswordShown.toggle()
          }, label: {
            Image(systemName: !isPasswordShown ? "eye.fill" : "eye.slash.fill")
              .foregroundStyle(.gray)
          })
        }
        .padding()
        .frame(height: 45)
        .overlay(
          RoundedRectangle(cornerRadius: 14)
            .stroke(focus ? Color(hex: LB.AppColors.textFieldFocused) : .gray, lineWidth: 2)
            .opacity(focus ? 1 : 0.5)
        )
      }
    }
    .padding(.bottom, 5)
  }
}

// MARK: - Custom Button
struct CustomButtonView: View {
  var name: String
  var isDisabled: Bool = false
  
  var body: some View {
    Text(name)
      .padding()
      .frame(maxWidth: .infinity)
      .background(isDisabled ? .accent.opacity(0.5) :  .accent)
      .foregroundStyle(.white)
      .fontWeight(.black)
      .clipShape(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50)))
      .padding(.top, 30)
  }
}

// MARK: - Custom Report Detail Label
struct ReportDetailLabelView: View {
  var data: String?
  var title: String
  var imageSystemName: String
  
  var body: some View {
    HStack {
      Image(systemName: "\(imageSystemName)")
        .foregroundStyle(.accent)
        .font(.title2)
        .frame(width: 20)
      VStack(alignment: .leading) {
        Text(verbatim: title)
          .font(.system(size: 12))
          .foregroundStyle(.gray)
        Text(data ?? "")
      }
    }
  }
}

#Preview {
  CustomButtonView(name: "Daftar", isDisabled: true)
    .previewLayout(.fixed(width: .infinity, height: 60))
    .previewDisplayName("Button")
}

#Preview {
  CustomTextFieldView(fieldBinding: .constant(""), fieldName: "Nama", isPassword: false)
}

#Preview {
  ReportDetailLabelView(data: "Sampel", title: "Judul nya", imageSystemName: "person.fill")
}

struct ContohView: View {
  var body: some View {
    Text("hello")
  }
}

#Preview {
  ContohView()
}
