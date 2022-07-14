//
//  ConnectionView.swift
//  AppScreenTransfer
//
//  Created by ashizawa on 2022/07/02.
//

import SwiftUI
import Combine

final class ConnectionViewModel {
    
    let qrViewController = QRReaderViewControllerWrapper()
    
    private var cancellables = [AnyCancellable]()
    
    @Published var url: String = ""
    
    
    init() {
        qrViewController.url.sink { error in
            print(error)
        } receiveValue: { url in
            self.url = url
        }.store(in: &cancellables)
    }
    
    func fetchUrlString() {
    }
    
    func setSubscrive() {
        qrViewController.url.sink { error in
            print(error)
        } receiveValue: { url in
            self.hoge()
        }.store(in: &self.cancellables)
        
//        self.qrViewController.stop()
    }
    
     func hoge() {
//        self.qrViewController.stop()
    }
    
}

struct ConnectionView: View {
    
//    private let qrViewController = QRReaderViewControllerWrapper()
    
    private let viewModel: ConnectionViewModel
    
    init(viewModel: ConnectionViewModel) {
        self.viewModel = viewModel
        
        viewModel.url.publisher.sink { url in
            print(url)
        }
    }
    
    var body: some View {
        viewModel.qrViewController
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView(viewModel: ConnectionViewModel())
    }
}
