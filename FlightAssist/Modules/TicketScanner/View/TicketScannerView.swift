//
//  TicketScannerView.swift
//  Project
//
//  Created by Danyah ALbarqawi on 07/04/2026.
//

import SwiftUI
import VisionKit

struct TicketScannerView: View {
    let onScan: (String) -> Void
    let onError: (String) -> Void
    
    var body: some View {
        TicketScannerRepresentable(onScan: onScan, onError: onError)
            .ignoresSafeArea()
    }
}

struct TicketScannerRepresentable: UIViewControllerRepresentable {
    let onScan: (String) -> Void
    let onError: (String) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan, onError: onError)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        let onError: (String) -> Void
        private var allText: [String] = []
        private var timer: Timer?
        
        init(onScan: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
            self.onScan = onScan
            self.onError = onError
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            // جمع كل النصوص
            allText = allItems.compactMap {
                if case .text(let text) = $0 { return text.transcript }
                return nil
            }
            
            // بعد ثانية يرسل النص كامل
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                let fullText = self.allText.joined(separator: "\n")
                if !fullText.isEmpty {
                    self.onScan(fullText)
                }
            }
        }
    }
}
