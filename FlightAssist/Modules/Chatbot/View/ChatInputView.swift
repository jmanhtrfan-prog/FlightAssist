//
//  ChatInputView.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(bubbleBackground)
                .foregroundColor(textColor)
                .cornerRadius(20)
                .font(.system(size: 16))
            
            if !message.isFromUser {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    // MARK: - Computed Properties
    
    private var bubbleBackground: Color {
        message.isFromUser ? AppColors.primary : AppColors.emptyCard
    }
    
    private var textColor: Color {
        message.isFromUser ? AppColors.white : AppColors.black
    }
}

// MARK: - Preview
struct MessageBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            MessageBubbleView(message: Message(content: "Hello! How can I help you?", isFromUser: false))
            MessageBubbleView(message: Message(content: "I need help with seat swapping", isFromUser: true))
        }
        .padding()
        .background(AppColors.background)
    }
}
