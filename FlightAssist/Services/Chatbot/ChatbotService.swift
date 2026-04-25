//
//  ChatbotService.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

import Foundation

enum ChatServiceError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case apiError(String)
}

class ChatService {
    
    // MARK: - Configuration
    private let apiKey: String
    private let baseURL: String
    private let model: String
    
    // System prompt for travel assistance context
    private let systemPrompt = """
    You are an intelligent travel assistant for FlightAssist, a travel app that helps passengers with:
    
    1. Seat swapping during or before flights
    2. Flight ticket scanning and management
    3. UM (Unaccompanied Minor) services - booking flight attendants for children traveling alone
    4. General flight and airport information
    
    Provide helpful, accurate, and friendly responses about flights, airports, seat changes, and travel services.
    Keep responses concise but informative. Always prioritize passenger safety and airline regulations.
    """
    
    // MARK: - Initialization
    
    /// Initialize with your preferred AI provider
    init(apiKey: String, provider: AIProvider = .groq) {
        self.apiKey = apiKey
        
        switch provider {
        case .groq:
            self.baseURL = "https://api.groq.com/openai/v1/chat/completions"
            // FIXED: Updated to current working model
            self.model = "llama-3.3-70b-versatile"  // New model name!
            
        case .claude:
            self.baseURL = "https://api.anthropic.com/v1/messages"
            self.model = "claude-3-5-sonnet-20241022"
            
        case .openAI:
            self.baseURL = "https://api.openai.com/v1/chat/completions"
            self.model = "gpt-4-turbo-preview"
            
        case .huggingFace:
            self.baseURL = "https://api-inference.huggingface.co/models/meta-llama/Meta-Llama-3-8B-Instruct"
            self.model = "meta-llama/Meta-Llama-3-8B-Instruct"
        }
    }
    
    // MARK: - Public Methods
    
    func sendMessage(_ message: String, conversationHistory: [Message]) async throws -> String {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Configure headers based on provider
        if baseURL.contains("anthropic") {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            
            let body = createClaudeRequestBody(message: message, history: conversationHistory)
            request.httpBody = try JSONEncoder().encode(body)
            
        } else if baseURL.contains("huggingface") {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let body = createHuggingFaceRequestBody(message: message, history: conversationHistory)
            request.httpBody = try JSONEncoder().encode(body)
            
        } else {
            // OpenAI-compatible (Groq, OpenAI)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let body = createOpenAIRequestBody(message: message, history: conversationHistory)
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ChatServiceError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        return try parseResponse(data: data)
    }
    
    // MARK: - Private Methods
    
    private func createClaudeRequestBody(message: String, history: [Message]) -> ClaudeRequest {
        var messages: [[String: String]] = []
        
        for msg in history {
            messages.append([
                "role": msg.isFromUser ? "user" : "assistant",
                "content": msg.content
            ])
        }
        
        messages.append([
            "role": "user",
            "content": message
        ])
        
        return ClaudeRequest(
            model: model,
            max_tokens: 1024,
            system: systemPrompt,
            messages: messages
        )
    }
    
    private func createOpenAIRequestBody(message: String, history: [Message]) -> OpenAIRequest {
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        for msg in history {
            messages.append([
                "role": msg.isFromUser ? "user" : "assistant",
                "content": msg.content
            ])
        }
        
        messages.append([
            "role": "user",
            "content": message
        ])
        
        return OpenAIRequest(
            model: model,
            messages: messages,
            temperature: 0.7,
            max_tokens: 1024
        )
    }
    
    private func createHuggingFaceRequestBody(message: String, history: [Message]) -> HuggingFaceRequest {
        var fullPrompt = systemPrompt + "\n\n"
        
        for msg in history.suffix(5) {
            let role = msg.isFromUser ? "User" : "Assistant"
            fullPrompt += "\(role): \(msg.content)\n"
        }
        
        fullPrompt += "User: \(message)\nAssistant:"
        
        return HuggingFaceRequest(
            inputs: fullPrompt,
            parameters: HuggingFaceParameters(
                max_new_tokens: 512,
                temperature: 0.7,
                return_full_text: false
            )
        )
    }
    
    private func parseResponse(data: Data) throws -> String {
        if baseURL.contains("anthropic") {
            let response = try JSONDecoder().decode(ClaudeResponse.self, from: data)
            return response.content.first?.text ?? ""
            
        } else if baseURL.contains("huggingface") {
            let response = try JSONDecoder().decode([HuggingFaceResponse].self, from: data)
            return response.first?.generated_text ?? ""
            
        } else {
            // OpenAI-compatible (Groq, OpenAI)
            let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            return response.choices.first?.message.content ?? ""
        }
    }
}

// MARK: - Supporting Types

enum AIProvider {
    case groq           // FREE - Recommended!
    case claude         // Paid - Best quality
    case openAI         // Paid - Also excellent
    case huggingFace    // FREE - Good alternative
}

// Claude API Models
struct ClaudeRequest: Codable {
    let model: String
    let max_tokens: Int
    let system: String
    let messages: [[String: String]]
}

struct ClaudeResponse: Codable {
    let content: [ClaudeContent]
    
    struct ClaudeContent: Codable {
        let text: String
    }
}

// OpenAI/Groq API Models (same format!)
struct OpenAIRequest: Codable {
    let model: String
    let messages: [[String: String]]
    let temperature: Double
    let max_tokens: Int
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: MessageContent
    }
    
    struct MessageContent: Codable {
        let content: String
    }
}

// HuggingFace API Models
struct HuggingFaceRequest: Codable {
    let inputs: String
    let parameters: HuggingFaceParameters
}

struct HuggingFaceParameters: Codable {
    let max_new_tokens: Int
    let temperature: Double
    let return_full_text: Bool
}

struct HuggingFaceResponse: Codable {
    let generated_text: String
}


