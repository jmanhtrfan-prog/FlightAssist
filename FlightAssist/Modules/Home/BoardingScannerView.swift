//
//  BoardingScannerView.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//

import SwiftUI
import VisionKit

struct BoardingScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void
    var onError: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan, onError: onError)
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [
                .barcode(symbologies: [.qr, .pdf417]),
                .text()
            ],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )

        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        guard DataScannerViewController.isSupported else {
            onError("This device does not support scanning")
            return
        }

        guard DataScannerViewController.isAvailable else {
            onError("Scanner is unavailable")
            return
        }

        do {
            if !uiViewController.isScanning {
                try uiViewController.startScanning()
            }
        } catch {
            onError("Failed to start scanner")
        }
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        let onError: (String) -> Void
        var didScan = false

        init(onScan: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
            self.onScan = onScan
            self.onError = onError
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            guard !didScan, let firstItem = addedItems.first else { return }
            didScan = true

            switch firstItem {
            case .barcode(let barcode):
                if let value = barcode.payloadStringValue, !value.isEmpty {
                    onScan(value)
                } else {
                    onError("No barcode data found")
                }

            case .text(let text):
                let value = text.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                if !value.isEmpty {
                    onScan(value)
                } else {
                    onError("No text found")
                }

            @unknown default:
                onError("Unsupported scanned item")
            }
        }
    }
}
