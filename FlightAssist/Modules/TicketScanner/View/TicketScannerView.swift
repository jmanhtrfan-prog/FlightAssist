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
            recognizedDataTypes: [.text(), .barcode()],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
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
        private var hasScanned = false

        init(onScan: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
            self.onScan = onScan
            self.onError = onError
        }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didUpdate updatedItems: [RecognizedItem],
                         allItems: [RecognizedItem]) {

            guard !hasScanned else { return }

            let text = allItems.compactMap {
                switch $0 {
                case .text(let t):
                    return t.transcript
                case .barcode(let b):
                    return b.payloadStringValue
                default:
                    return nil
                }
            }.joined(separator: "\n")

            print("SCANNED TEXT:\n\(text)")

            if !text.isEmpty {
                hasScanned = true
                onScan(text)
            }
        }
    }
}
// 🔹 Preview
#Preview {
    let defaults = UserDefaults.standard
    defaults.set(["Find my seat", "Change seats"], forKey: "recentServicesStorage")
    return HomeView()
}
