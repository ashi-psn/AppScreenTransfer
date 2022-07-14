import ReplayKit
import Combine
import HaishinKit

protocol CaptureHandlable {
    func start() throws
    func stop() throws
}

protocol RTMPSendable {
    var url: String { get }
    var rtmpConnection: RTMPConnection { get }
    var rtmpStream: RTMPStream { get }
    
    func attachMediaSource()
}

public enum RecoederError: Error {
    case notAvailable
    case alreadyRunning
    case notRunning
    case invalidURL
}

class CaptureManager: NSObject, CaptureHandlable, RTMPSendable {
    
    var url: String
    
    private let recorder = RPScreenRecorder.shared()
    
    private var stream = PassthroughSubject<CMSampleBuffer, Never>()
    
    var rtmpConnection: RTMPConnection = RTMPConnection()
    
    var rtmpStream: RTMPStream
    
    
    init(rtmpURL: String) {
        self.url = rtmpURL
        rtmpStream = RTMPStream(connection: rtmpConnection)
        super.init()
    }
    
    func attachMediaSource() {
        rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio)) { error in
            // print(error)
        }
        rtmpStream.attachCamera(DeviceUtil.device(withPosition: .back)) { error in
            // print(error)
        }
    }
    
    func start() throws {
//        guard recorder.isAvailable else {
//            throw RecoederError.notAvailable
//        }
//
//        guard !recorder.isRecording else {
//            throw RecoederError.alreadyRunning
//        }
        
        attachMediaSource()
        
//        recorder.startCapture { buffer, bufferType, error in
//            switch bufferType{
//            case .video:
////                self.rtmpStream.appendSampleBuffer(buffer, withType: .video)
//                print()
//            case .audioApp:
//                print()
//            case .audioMic:
//                print()
//            @unknown default:
//                fatalError()
//            }
//        } completionHandler: { error in
//            guard let error = error else { return }
//            print(error)
//        }
        
        
        
        rtmpConnection.connect("rtmp://localhost/live/")
        rtmpStream.publish("test")
    }
    
    func stop() throws {
        guard !recorder.isRecording else {
            throw RecoederError.notRunning
        }
        
        recorder.stopCapture { error in
            guard let error = error else { return }
            
            print(error)
        }
        rtmpStream.close()
    }
}
