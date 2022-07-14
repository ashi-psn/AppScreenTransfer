//
//  QRReader.swift
//  AppScreenTransfer
//
//  Created by ashizawa on 2022/07/06.
//

import UIKit
import SwiftUI
import AVFoundation
import Combine

enum QRReaderError: String, Error {
    case camera_not_found
    case input_not_found
}

private class QRReader: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    let queue = DispatchQueue.global(qos: .background)
    
    let url = PassthroughSubject<String, QRReaderError>()
    
    private let sesseion = AVCaptureSession()
    
    private let metadataOutput = AVCaptureMetadataOutput()
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first else { return }
        
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else  { return }
        
        guard let value = readableObject.stringValue else { return }
        
        url.send(value)
    }
    
    func attach(view: UIView) throws {
        guard let camera = AVCaptureDevice.default(for: .video) else {
            throw QRReaderError.camera_not_found
        }
        
        let input = try AVCaptureDeviceInput(device: camera)
        
        sesseion.sessionPreset = .photo
        
        if sesseion.canAddInput(input) {
            sesseion.addInput(input)
        }
        
        if sesseion.canAddOutput(metadataOutput) {
            sesseion.addOutput(metadataOutput)
            metadataOutput.metadataObjectTypes = [.qr]
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        }
        
        sesseion.sessionPreset = .photo
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.sesseion)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        start()
    }
    
    func start() {
        
        queue.async {
            self.sesseion.startRunning()
        }
    }
    
    func stop() {
        queue.async {
            self.sesseion.stopRunning()
            self.detachSession()
        }
    }
    
    private func detachSession() {
        sesseion.inputs.forEach {
            sesseion.removeInput($0)
        }
        
        sesseion.outputs.forEach {
            sesseion.removeOutput($0)
        }
    }
    
    func isRunning() -> Bool {
        return sesseion.isRunning
    }
}


class QRReaderViewController: UIViewController {
    
    private let qrReader = QRReader()
    
    var url: PassthroughSubject<String, QRReaderError> {
        qrReader.url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? qrReader.attach(view: view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        qrReader.stop()
    }
    
    func start() {
        qrReader.start()
    }
    
    func stop() {
        qrReader.stop()
    }
}

struct QRReaderViewControllerWrapper: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = QRReaderViewController
    
    let viewController = QRReaderViewController()
    
    var url: PassthroughSubject<String, QRReaderError> {
        viewController.url
    }
    
    func makeUIViewController(context: Context) -> QRReaderViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: QRReaderViewController, context: Context) {
        
    }
    
    func stop() {
        viewController.stop()
    }
    
}
