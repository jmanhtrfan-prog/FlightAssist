//
//  LoginView.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//
import SwiftUI

struct LoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        LoginModel.white,
                        LoginModel.primary,
                        LoginModel.secondary
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Text("AiR")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(LoginModel.white)
                        
                        Image(systemName: "airplane")
                            .foregroundColor(LoginModel.white)
                    }
                    
                    Text("Welcome Back!")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(LoginModel.white)
                    
                    Rectangle()
                        .fill(LoginModel.white.opacity(0.4))
                        .frame(width: 140, height: 1)
                    
                    VStack(spacing: 18) {
                        
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(LoginModel.cardPurple)
                            
                            TextField("Username", text: $viewModel.loginModel.username)
                                .foregroundColor(LoginModel.black)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(LoginModel.textFieldBackground)
                        .cornerRadius(16)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(LoginModel.cardPurple)
                            
                            Group {
                                if viewModel.loginModel.showPassword {
                                    TextField("Password", text: $viewModel.loginModel.password)
                                } else {
                                    SecureField("Password", text: $viewModel.loginModel.password)
                                }
                            }
                            .foregroundColor(LoginModel.black)
                            
                            Button {
                                viewModel.togglePasswordVisibility()
                            } label: {
                                Image(systemName: viewModel.loginModel.showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(LoginModel.cardPurple)
                            }
                        }
                        .padding()
                        .background(LoginModel.textFieldBackground)
                        .cornerRadius(16)
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        Button {
                            viewModel.login()
                        } label: {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(LoginModel.white)
                                } else {
                                    Text("Log In")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(LoginModel.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [LoginModel.primary, LoginModel.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(18)
                            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 5)
                        }
                        .disabled(viewModel.isLoading)
                        
                        Button("Forgot Password?") {
                            viewModel.forgotPassword()
                        }
                        .foregroundColor(LoginModel.white)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Image(systemName: "airplane")
                            .font(.system(size: 50))
                            .foregroundColor(LoginModel.white.opacity(0.9))
                            .rotationEffect(.degrees(-20))
                            .padding(.trailing, 30)
                            .padding(.bottom, 30)
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                HomeView()
            }
        }
    }
}

#Preview {
    LoginView()
}
