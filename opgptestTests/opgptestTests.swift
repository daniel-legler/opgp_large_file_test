import XCTest
@testable import opgptest
import ObjectivePGP

class opgptestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testReadingLargeKeyringFileFromData() {
        report_memory()
        
        let keysDataUrl = Bundle(for: type(of: self)).url(forResource: "pubring", withExtension: "gpg")!
        do {
            let data = try Data(contentsOf: keysDataUrl)
            print("Size of Key Data (in MB): \(Float(data.count)/1024/1024)")
            _ = try ObjectivePGP.readKeys(from: data)
            report_memory()
        } catch {
            XCTFail()
        }
    }
    
    func testReadingLargeKeyringFileFromFile() {
        report_memory()
        
        let keysDataUrl = Bundle(for: type(of: self)).url(forResource: "pubring", withExtension: "gpg")!
        do {
            _ = try ObjectivePGP.readKeys(fromPath: keysDataUrl.path)
            report_memory()
        } catch {
            XCTFail()
        }
    }

    func testLargeFileEncryption() {
        
        report_memory()
        guard let dataUrl = Bundle(for: type(of: self)).url(forResource: "LargeFile", withExtension: "pdf") else {
            XCTFail("Failed to find test file")
            return
        }
        
        do {
            let data = try Data(contentsOf: dataUrl)
            
            print("Size of Unencrypted Data (in MB): \(Float(data.count)/1024/1024)")
            
            let pubKey = TestHelpers.objectivePgpPublicKey
            let armoredData = try Armor.readArmored(pubKey)
            let key = try ObjectivePGP.readKeys(from: armoredData)
            
            report_memory()
            
            let encryptedData = try ObjectivePGP.encrypt(data, addSignature: false, using: key)
            
            report_memory()
            
            print("Size of Encrypted Data (in MB): \(Float(encryptedData.count)/1024/1024)")
            
            sleep(10) // To observe memory usage in Xcode also
            
        } catch {
            XCTFail("Couldn't generate data from test file")
        }
    }
    
    func report_memory() {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            print("System Memory Used (in MB): \(Float(taskInfo.resident_size)/1024/1024)")
        } else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
        }
    }
}
