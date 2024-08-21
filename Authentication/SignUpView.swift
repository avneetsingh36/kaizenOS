import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}


@MainActor
final class SignUpEmailViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""  // For sign-up only
    @Published var passwordIsSecured: Bool = true
    @Published var confirmPasswordIsSecured: Bool = true // For password visibility toggle
    @Published var acceptsTerms: Bool = false     // For sign-up only, if needed
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found!")
            return
        }
    
     
        try await AuthenticationManager.shared.createUser(email: email, password: password)
      
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



struct SignUpView: View {
    
    @StateObject private var viewModel = SignUpEmailViewModel()
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
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "000000"), Color(hex: "#130F40")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            
                VStack(spacing: 20) {

                    dragDown
                    topText
                    emailField
                    passwordField
                    logInButton
                    logInOptions
                    
                    // left in case I need this again
                    //GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .icon, state: .normal)) { }
                    
                    Spacer()
                
                
                }
                .padding()

        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
        
    }
    
    var dragDown: some View {
        VStack {
            Image(systemName: "chevron.compact.down")
                .imageScale(.large)
                .foregroundColor(.white)
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                
        }
    }
    
    var topText: some View {
        VStack {
            Text("Sign Up")
                .foregroundColor(.white)
                .font(.system(.largeTitle, design: .serif))
                .fontWeight(.semibold)
                .padding(.vertical, 20)
        }
    }
    
    var emailField: some View {
        VStack(alignment: .leading) {
            TextField("", text: $viewModel.email, prompt: Text("Email").foregroundColor(.gray))
                .customTextFieldStyle()
                .keyboardType(.emailAddress)
        }
    }
    
    var passwordField: some View {
        VStack(alignment: .leading) {

            ZStack (alignment: .trailing) {
                Group {
                    if viewModel.passwordIsSecured {
                        SecureField("", text: $viewModel.password, prompt: Text("Password").foregroundColor(.gray))
                            .customTextFieldStyle()
                    } else {
                        TextField("", text: $viewModel.password, prompt: Text("Password").foregroundColor(.gray))
                            .customTextFieldStyle()
                    }
                }
                
                Button(action: {
                    viewModel.passwordIsSecured.toggle()
                }) {
                    Image(systemName: self.viewModel.passwordIsSecured ? "eye.slash" : "eye")
                        .accentColor(.accent).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .padding(.trailing, 15)
                }
                
            }
        }
    }
    
    var confirmPasswordField: some View {
        VStack(alignment: .leading) {

            ZStack (alignment: .trailing) {
                Group {
                    if viewModel.confirmPasswordIsSecured {
                        SecureField("", text: $viewModel.confirmPassword, prompt: Text("Confirm Password").foregroundColor(.gray))
                            .customTextFieldStyle()
                    } else {
                        TextField("", text: $viewModel.confirmPassword, prompt: Text("Confirm Password").foregroundColor(.gray))
                            .customTextFieldStyle()
                    }
                }
                
                Button(action: {
                    viewModel.confirmPasswordIsSecured.toggle()
                }) {
                    Image(systemName: self.viewModel.confirmPasswordIsSecured ? "eye.slash" : "eye")
                        .accentColor(.accent).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .padding(.trailing, 15)
                }
            }

        }
        .padding(.bottom, 10)
    }

    
    var logInButton: some View {
        VStack {
            Button(action: {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                    
                }
            }) {
                Label("Sign Up", systemImage: "arrow.right")
                    .mainButtonStyle()
            }
        }
        .padding(.bottom, 5)
    }
    
    var logInOptions: some View {
        VStack {
            HStack {
                Rectangle().frame(height: 1).opacity(0.3)
                    .foregroundColor(.white)
                Text("OR")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .opacity(0.4)
                Rectangle().frame(height: 1).opacity(0.3)
                    .foregroundColor(.white)
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
                        Text("Sign in with Google")
                    }
                    .secondaryButtonStyle()
                }
            }
        }
    }
}


#Preview {
    SignUpView(showSignInView: .constant(false))
}

