//
//  ChatbotView.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

import SwiftUI

struct ChatbotView: View {
    @StateObject private var viewModel: ChatbotViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool
    
    init() {
        _viewModel = StateObject(wrappedValue: ChatbotViewModel())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            messagesScrollView
            inputArea
        }
        .background(AppColors.background)
        .navigationBarHidden(true)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }
    
    // MARK: - Header
    private var header: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.primary)
                .frame(height: 100)
                .ignoresSafeArea(edges: .top)
            
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Chat bot")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
        }
        .frame(height: 100)
    }
    
    // MARK: - Messages Scroll View
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                    
                    if viewModel.isLoading {
                        HStack {
                            LoadingDotsView()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(AppColors.emptyCard)
                                .cornerRadius(20)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Input Area
    private var inputArea: some View {
        VStack(spacing: 0) {
            Divider()
                .background(AppColors.emptyCard)
            
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.gray)
                }
                
                TextField("Type a message...", text: $viewModel.currentInput)
                    .focused($isInputFocused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.textFieldBackground)
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(AppColors.emptyCard, lineWidth: 1)
                    )
                    .onSubmit {
                        viewModel.sendMessage()
                    }
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(viewModel.currentInput.isEmpty ? AppColors.gray.opacity(0.5) : AppColors.primary)
                }
                .disabled(viewModel.currentInput.isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(AppColors.white)
    }
}

// MARK: - Loading Dots View
struct LoadingDotsView: View {
    @State private var animationAmount = 0
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(AppColors.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationAmount == index ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationAmount
                    )
            }
        }
        .onAppear {
            animationAmount = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animationAmount = 1
            }
        }
    }
}

// MARK: - Preview
struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatbotView()
        }
    }
}
