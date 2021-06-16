//
//  ContentView.swift
//  FormWithCombine
//
//  Created by Anselm Jade Jamig on 6/16/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var formViewModel = FormViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("USERNAME")) {
                        TextField("Username", text: self.$formViewModel.username)
                            .autocapitalization(.none)
                    }
                    Section(header: Text("PASSWORD"), footer: Text(self.formViewModel.inlineErrorForPassword).foregroundColor(.red)) {
                        SecureField("Password", text: self.$formViewModel.password)
                        SecureField("Password again", text: self.$formViewModel.passwordAgain)
                    }
                    
                }
//                .frame(height: 200)
                
                Button(action: {}) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .frame(height: 60)
                        .overlay(
                            Text("Continue")
                                .foregroundColor(.white)
                        )
                }
                .padding()
                
                //.disabled(!self.formViewModel.isValid)
                
            }
            .navigationTitle("Sign up")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
