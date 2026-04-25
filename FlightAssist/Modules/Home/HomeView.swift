//
//  HomeView.swift
//  FlightAssist
//
//  Created by danah alsadan on 20/10/1447 AH.
//

import SwiftUI
import VisionKit
import AVFoundation

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showScanner = false
    @State private var searchText = ""

    private let mapAssetName = "topMap"
    private let seatsAssetName = "serviceSeats"
    private let lightCard = Color(red: 247/255, green: 241/255, blue: 246/255)
    private let serviceColor = Color(red: 83/255, green: 42/255, blue: 92/255)
    private let mainPurple = Color(red: 83/255, green: 42/255, blue: 92/255)
    private let bottomBarColor = Color(red: 231/255, green: 223/255, blue: 235/255)
    private let secondaryTextColor = Color(red: 88/255, green: 82/255, blue: 94/255)

    private var filteredServices: [String] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return viewModel.recentServices
        } else {
            return viewModel.recentServices.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    topMapSection
                    mainCard.padding(.top, -3)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.white)

                bottomBar
            }
            // ✅ الكاميرا شفافة — تظهر الخلفية من ورا
            .fullScreenCover(isPresented: $showScanner, onDismiss: {
                viewModel.fetchTicketFromCloudKit()
            }) {
                TransparentScannerView(onDismiss: {
                    showScanner = false
                })
            }
            .alert(
                "Scanner",
                isPresented: Binding(
                    get: { viewModel.scannerError != nil },
                    set: { _ in viewModel.scannerError = nil }
                )
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.scannerError ?? "")
            }
            .onDisappear {
                viewModel.clearBoardingPass()
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - TransparentScannerView
// تظهر الكاميرا الحقيقية بدون تعتيم — كأنها تقرأ التذكرة
struct TransparentScannerView: UIViewControllerRepresentable {
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> TransparentCameraVC {
        TransparentCameraVC(onDismiss: onDismiss)
    }

    func updateUIViewController(_ uiViewController: TransparentCameraVC, context: Context) {}
}

class TransparentCameraVC: UIViewController {
    let onDismiss: () -> Void
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var timer: Timer?

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()

        // بعد ثانيتين يغلق تلقائي
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.onDismiss()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        captureSession?.stopRunning()
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        session.addInput(input)
        session.startRunning()

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)

        self.captureSession = session
        self.previewLayer = preview
    }

    private func setupUI() {
        // إطار السكان فوق الكاميرا
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)

        // إطار مستطيل للسكان
        let scanFrame = UIView()
        scanFrame.translatesAutoresizingMaskIntoConstraints = false
        scanFrame.layer.borderColor = UIColor.white.cgColor
        scanFrame.layer.borderWidth = 2
        scanFrame.layer.cornerRadius = 12
        view.addSubview(scanFrame)

        // خط السكان الأخضر
        let scanLine = UIView()
        scanLine.translatesAutoresizingMaskIntoConstraints = false
        scanLine.backgroundColor = UIColor.green.withAlphaComponent(0.8)
        view.addSubview(scanLine)

        // نص
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Scanning ticket..."
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        view.addSubview(label)

        NSLayoutConstraint.activate([
            scanFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanFrame.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanFrame.widthAnchor.constraint(equalToConstant: 280),
            scanFrame.heightAnchor.constraint(equalToConstant: 180),

            scanLine.centerXAnchor.constraint(equalTo: scanFrame.centerXAnchor),
            scanLine.centerYAnchor.constraint(equalTo: scanFrame.centerYAnchor),
            scanLine.widthAnchor.constraint(equalToConstant: 280),
            scanLine.heightAnchor.constraint(equalToConstant: 2),

            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: scanFrame.bottomAnchor, constant: 20),
        ])

        // تحريك خط السكان
        UIView.animate(withDuration: 1.5, delay: 0,
                       options: [.autoreverse, .repeat, .curveEaseInOut]) {
            scanLine.transform = CGAffineTransform(translationX: 0, y: 80)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
}

// MARK: - HomeView Extensions
private extension HomeView {

    var topMapSection: some View {
        VStack(spacing: 0) {
            Image(mapAssetName)
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .padding(.horizontal, -1)
                .padding(.top, -65)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }

    var mainCard: some View {
        VStack(spacing: 18) {
            if viewModel.isLoadingTicket {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(mainPurple)
                    Text("Loading your ticket...")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else if let info = viewModel.boardingPassInfo {
                boardingCard(info).padding(.top, 46)
            } else {
                scanBox.padding(.top, 46)
            }

            searchBar

            if !viewModel.recentServices.isEmpty {
                recentServicesSection
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 90)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 34)
                .fill(Color.white)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    var scanBox: some View {
        Button {
            showScanner = true
        } label: {
            VStack(spacing: 12) {
                Image(systemName: "camera")
                    .font(.system(size: 34, weight: .regular))
                Text("Scan the ticket")
                    .font(.system(size: 17, weight: .medium))
            }
            .foregroundColor(.black)
            .frame(width: 220, height: 150)
            .background(lightCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    var searchBar: some View {
        HStack(spacing: 8) {
            TextField("Search service", text: $searchText)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20))
                .foregroundColor(.gray.opacity(0.8))
        }
        .padding(.horizontal, 18)
        .frame(height: 54)
        .background(lightCard)
        .clipShape(Capsule())
    }

    var recentServicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent services")
                .font(.system(size: 17))
                .foregroundColor(.gray.opacity(0.9))

            if filteredServices.isEmpty {
                Text("No matching services")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(filteredServices, id: \.self) { service in
                            recentServiceCard(title: service)
                        }
                    }
                    .padding(.trailing, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func recentServiceCard(title: String) -> some View {
        Button {
            viewModel.saveRecentService(title)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(serviceColor)
                    .frame(width: 165, height: 66)

                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    serviceImage(for: title)
                }
                .padding(.leading, 16)
                .padding(.trailing, 10)
                .frame(width: 165)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func serviceImage(for title: String) -> some View {
        if title.lowercased().contains("chat") {
            ZStack {
                Image("Chat2").resizable().scaledToFit().frame(width: 42, height: 42)
                Image("Chat1").resizable().scaledToFit().frame(width: 28, height: 28).offset(x: 8, y: 3)
            }
            .frame(width: 48, height: 42)
        } else if title.lowercased().contains("update") {
            Image("bellCard").resizable().scaledToFit().frame(width: 42, height: 42)
        } else if title.lowercased().contains("child") {
            Image("اطفال").resizable().scaledToFit().frame(width: 42, height: 42)
        } else {
            Image(seatsAssetName).resizable().scaledToFit().frame(width: 42, height: 42)
        }
    }

    func boardingCard(_ info: BoardingPassInfo) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(info.fullName)
                .font(.title3.bold())
                .foregroundColor(.black)

            HStack {
                infoItem("Flight", info.flightNumber)
                Spacer()
                infoItem("From", info.from)
                Spacer()
                infoItem("To", info.to)
            }

            Divider()

            HStack {
                infoItem("Gate", info.gate)
                Spacer()
                infoItem("Seat", info.seat)
                Spacer()
                infoItem("Boarding", info.boardingTime)
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    func infoItem(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body.bold())
                .foregroundColor(.black)
        }
    }

    var bottomBar: some View {
        HStack {
            Spacer()
            bottomItem(icon: "house.fill", title: "Home", selected: true)
            Spacer()
            // ✅ زر Survices يرجع لـ SeatsServicesView
            NavigationLink(destination: SeatsServicesView().navigationBarBackButtonHidden(true)) {
                bottomItem(icon: "square.grid.2x2.fill", title: "Survices", selected: false)
            }
            .buttonStyle(.plain)
            .transaction { $0.animation = nil }
            Spacer()
            bottomItem(icon: "person", title: "Profile", selected: false)
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, -15)
        .background(bottomBarColor)
    }

    func bottomItem(icon: String, title: String, selected: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                if selected {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(mainPurple.opacity(0.14))
                        .frame(width: 84, height: 46)
                }
                Image(systemName: icon)
                    .font(.system(size: 21))
                    .foregroundColor(selected ? mainPurple : secondaryTextColor)
            }
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(selected ? mainPurple : secondaryTextColor)
        }
    }
}

#Preview {
    let defaults = UserDefaults.standard
    defaults.set("Change seats,Updates,Chat bot,Child trip", forKey: "recentServicesStorage")
    return HomeView()
}
