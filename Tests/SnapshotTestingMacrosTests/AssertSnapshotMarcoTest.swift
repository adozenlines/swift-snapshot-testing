import XCTest
import SwiftUI
import SnapshotMacros
import SnapshotTesting


final class AssertSnapshotTestingMacroTests: XCTestCase {
    func testData() {
        let data = Data([0x54, 0x42, 0x44, 0x45])
        if let value = String(data: data, encoding: .utf8) {
            #AssertSnapshotEqual(of: value, as: .lines)
        } else {
            XCTFail("Failed to convert data")
        }
    }
    
    func testView() {
        struct AView: View {
            var body: some View {
                Text("Hello SnapshotTesting")
                    .font(.largeTitle)
                #if os(macOS)
                    .frame(width: 1024, height: 640)
                #elseif os(iOS)
                    .frame(width: 390, height: 844)
                #elseif os(tvOS)
                    .frame(width: 3840, height:2160)
                #else
                    .frame(width: 120, height: 80)
                #endif
            }
        }
        
        let view = AView()
        #if os(macOS)
        let controller = NSHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 1024, height: 640)
        #AssertSnapshotEqual(of: controller, as: .image, named: named, record: false, timeout: 3.0)
        #elseif os(tvOS)
        let controller = UIHostingController(rootView: view)
        #AssertSnapshotEqual(of: controller, as: .image(on: .tv4K), named: named, record: false, timeout: 3.0)
        #else
        let controller = UIHostingController(rootView: view)
        #AssertSnapshotEqual(of: controller, as: .image(on: .iPhone13), named: named, record: false, timeout: 3.0)
        #endif
    }
    
    private var named: String {
        #if os(macOS)
        let name = "macOS"
        #elseif os(iOS)
        let name = "iOS"
        #elseif os(visionOS)
        let name = "visionOS"
        #elseif os(tvOS)
        let name = "tvOS"
        #else
        let name = "watchOS"
        #endif
        return name
    }
}
