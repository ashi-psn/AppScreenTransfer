import SwiftUI
import ReplayKit
import HaishinKit

struct StartView: View {
    
    let recorder = RPScreenRecorder.shared()
    @State var statusText: String = "停止中"
    
    let captureManager = CaptureManager(rtmpURL: "localhost")
    
    var body: some View {
        VStack{
            Button {
               startRecording()
            } label: {
                Text(statusText)
                    .font(.title)
            }
        }
    }
    
    func startRecording() {
        try! captureManager.start()
    }
    
    func stopRecording() {
        try! captureManager.stop()
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
