//
//  ChatbotViewModel.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//
import Foundation
import SwiftUI

@MainActor
class ChatbotViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var currentInput: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let chatService: ChatService
    private let maxHistoryCount = 20
    
    // MARK: - INIT
    init(chatService: ChatService? = nil) {
        
        // ✅ نجيب الـ API Key هنا بشكل آمن
        let apiKey = ProcessInfo.processInfo.environment["GROQ_API_KEY"] ?? ""
        
        if apiKey.isEmpty {
            fatalError("❌ Missing GROQ_API_KEY in environment variables")
        }
        
        if let service = chatService {
            self.chatService = service
        } else {
            self.chatService = ChatService(
                apiKey: apiKey,
                provider: .groq
            )
        }
        
        addBotMessage("Hello! How can I help you today?")
    }
    
    func sendMessage() {
        guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let userMessage = currentInput
        currentInput = ""
        
        addUserMessage(userMessage)
        
        Task {
            await fetchBotResponse(for: userMessage)
        }
    }
    
    private func fetchBotResponse(for userMessage: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let history = Array(messages.dropLast().suffix(maxHistoryCount))
            
            let response = try await chatService.sendMessage(
                userMessage,
                conversationHistory: history
            )
            
            addBotMessage(response)
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func addUserMessage(_ text: String) {
        messages.append(Message(content: text, isFromUser: true))
    }
    
    private func addBotMessage(_ text: String) {
        messages.append(Message(content: text, isFromUser: false))
    }
}
