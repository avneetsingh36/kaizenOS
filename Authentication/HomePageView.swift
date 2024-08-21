import SwiftUI
import RiveRuntime

struct HomePageView: View {
    
    @State private var showSheet = false
    @Binding var showSignInView: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea() // Black background permanence
                backgroundView
                gearIcon
                mainContent
                bottomContent
            }
        }
        .sheet(isPresented: $showSheet) {
            SignUpView(showSignInView: $showSignInView)
                .presentationDetents([.fraction(0.96)])
                //.presentationDragIndicator(.visible)
                //.presentationDetents([.large])
                //.interactiveDismissDisabled() -> maybe add when paywall
        }
    }
    
    var mainContent: some View {
        ZStack {
            VStack {
                Text("Do more by")
                Text("doing less.")
            }
            .font(.system(.title, design: .serif))
            .foregroundColor(.white)
            .padding(.bottom, 140)
        }
    }
    
    var bottomContent: some View {
        VStack(alignment: .center) {
            Spacer()
            Button(action: {
                showSheet.toggle()
            }) {
                Text("Join")
                    .foregroundColor(Color.white)
                    .fontWeight(.semibold)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.106, green: 0.106, blue: 0.106))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
            }
            
            NavigationLink(destination: SignInView(showSignInView: $showSignInView)) {
                Text("Log In")
                    .mainButtonStyle()
                    .padding(.vertical, 10)
                    .padding(.bottom, 5)
                    .padding(.horizontal, 20)
            }
            
            Text("By continuing you agree to our Terms of Use and Privacy Policy")
                .frame(width: 240)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.footnote)
                .opacity(0.6)
        }
    }
    
    var gearIcon: some View {
        Image(systemName: "gearshape")
            .imageScale(.large)
            .foregroundColor(.white)
            .opacity(0.6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.horizontal, 15)
            .onTapGesture {
                print("You hit the gear!")
            }
    }
    
    var backgroundView: some View {
        VStack {
            RiveViewModel(fileName: "mainA").view()
                .blur(radius: 15)
                .padding(.bottom, 60)
        }
    }
}

#Preview {
    HomePageView(showSignInView: .constant(false))
}
