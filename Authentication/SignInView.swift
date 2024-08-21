//
//  SignInView.swift
//  KaizenOS
//
//  Created by Avneet Singh on 5/8/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


@MainActor
final class SignInEmailViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSecured: Bool = true  // To handle password visibility toggle
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found!")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
      
    }
    
    func signInGoogle() async throws {
        guard let topVC = Utilities.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        
    }
}



struct SignInView: View {
    
    @ObservedObject private var viewModel = SignInEmailViewModel()
    
    @Binding var showSignInView: Bool
    
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var btnBack: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.backward.circle")
                .foregroundColor(.accent)
                .imageScale(.large)
        }
    }
    
    var body: some View {
        
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack (spacing: 20) {
                
                headingText
                
                fields
                
                logInButton
                
                logInOptions
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .foregroundColor(.white)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
    }

    

    
    var headingText: some View {
        VStack {
            Text("Log In")
                .font(.system(.largeTitle, design: .serif))
                .fontWeight(.semibold)
                .padding(.bottom, 20)

            
            Text("Streamline your productivity and manage your projects effortlessly.")
                .multilineTextAlignment(.center)
                .font(.system(.headline, design: .serif))
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
        }
    }
    
    
    
    var fields: some View {
        VStack(alignment: .leading) {
            TextField("", text: $viewModel.email, prompt: Text("Email").foregroundColor(.gray))
                .customTextFieldStyle()
                .keyboardType(.emailAddress)
                .padding(.bottom, 15)

            ZStack (alignment: .trailing) {
                Group {
                    if viewModel.isSecured {
                        SecureField("", text: $viewModel.password, prompt: Text("Password").foregroundColor(.gray))
                            .customTextFieldStyle()
                    } else {
                        TextField("", text: $viewModel.password, prompt: Text("Password").foregroundColor(.gray))
                            .customTextFieldStyle()
                    }
                }
                
                HStack {
                    Button(action: {
                        viewModel.isSecured.toggle()
                    }) {
                        Image(systemName: self.viewModel.isSecured ? "eye.slash" : "eye")
                            .accentColor(.accent).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    }
                .padding(.trailing, 15)
                }
                .frame(height: 50)
            }
            
            
            HStack {
                Spacer()
                Text("Reset Password")
                    .font(.subheadline)
                    .padding(.top, 15)
                    .padding(.trailing, 5)
                    .opacity(0.8)
            }
        }
        .padding(.bottom, 15)
    }

    
    
    var logInButton: some View {
        VStack {
            Button(action: {
                Task {
                    do {
                        print("WE HERE")
                        try await viewModel.signIn()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                    
                }
            }) {
                Label("Log In", systemImage: "arrow.right")
                    .mainButtonStyle()
            }
        }
        .padding(.bottom, 5)
    }
    
    var logInOptions: some View {
        VStack {
            HStack {
                Rectangle().frame(height: 1).opacity(0.1)
                Text("OR")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .opacity(0.3)
                Rectangle().frame(height: 1).opacity(0.1)
            }
            .padding(.bottom, 20)

            VStack(spacing: 20) {
                Button(action: {
                    Task {
                        do {
                            try await viewModel.signInGoogle()
                            showSignInView = false
                        } catch {
                            print(error)
                        }
                    }
                }) {
                    
                    
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .foregroundColor(.red)
                        Text("Continue with Google")
                    }
                    .secondaryButtonStyle()
                }
            }
        }
    }
}

#Preview {
    SignInView(showSignInView: .constant(false))
}
