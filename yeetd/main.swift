//
//  main.swift
//  yeetd
//
//  Created by Michael Thomas on 9/20/23.
//

import Foundation
import OSLog

UserDefaults.standard.setValue(true, forKey: "killapsd")

// TODO: should probably just have these in a file somewhere
var processesToWatch: Set<String> {
    var processes: Set<String> = [
        "AegirPoster",
        "InfographPoster",
        "CollectionsPoster",
        "ExtragalacticPoster",
        "KaleidoscopePoster",
        "EmojiPosterExtension",
        "AmbientPhotoFramePosterProvider",
        "PhotosPosterProvider",
        "AvatarPosterExtension",
        "GradientPosterExtension",
        "MonogramPosterExtension"
    ]
    if UserDefaults.standard.bool(forKey: "killapsd") {
        processes.insert("apsd")
    }
    return processes
}

/***
 These processes may cause issues if they're killed, but also tend to consume a good bit of CPU
 - maild
 - apsd
 - NewsToday2
 - healthappd
 - diagnosticd **NOTE - this breaks the Console output and MAY causes boot issues, not recommended**
 */

// This is used to ensure we only kill Simulator processes and not host OS processes
let simulatorPathSearchKey = "simruntime/Contents/Resources/RuntimeRoot"

// How long to sleep between checks
let sleepDelay: UInt32 = 5

// ty Saagar for reminding me of the fun things you can do with Swift
let proc_listallpids = unsafeBitCast(dlsym(dlopen(nil, RTLD_LAZY | RTLD_NOLOAD), "proc_listallpids"), to: (@convention (c) (UnsafeRawPointer?, CInt) -> CInt)?.self)!
private let THREAD_IDENTIFIER_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<thread_identifier_info_data_t>.size / MemoryLayout<UInt32>.size)

while(true) {
    Logger.processManagement.info("Scanning for processes ...")
    
    // Get PIDs
    let count = proc_listallpids(nil, 0)
    let pids = [pid_t].init(unsafeUninitializedCapacity: Int(count)) {
        $1 = Int(proc_listallpids($0.baseAddress, count * CInt(MemoryLayout<pid_t>.stride)))
    }

    // Now, get the names so we can match
    for pid in pids {
        // Allocate buffers to store important things
        let nameBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(MAXPATHLEN))
        let pathBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(MAXPATHLEN))

        defer {
            nameBuffer.deallocate()
            pathBuffer.deallocate()
        }
        
        // proc_pidpath
        // Now get and print the name. Not all processes return a name here...
        let nameLength = proc_name(pid, nameBuffer, UInt32(MAXPATHLEN))
        let pathLength = proc_pidpath(pid, pathBuffer, UInt32(MAXPATHLEN))

        guard nameLength > 0, pathLength > 0 else { continue }

        let name = String(cString: nameBuffer)
        let path = String(cString: pathBuffer)

        if processesToWatch.contains(where: { $0 == name }) {
            // TODO: determine if a process is sleeping and be efficient
            // We need either:
            // 1) get-task-allow entitlement (no SIP)
            // 2) ps aux will return the state, we could pipe that command and read the state that way
            
            // Determine if the process is running in the Simulator or host OS
            if path.contains(simulatorPathSearchKey) {
                Logger.processManagement.info("Stopping process: \(name), PID: \(pid)")
                
                // Ride or Die™
                kill(pid, SIGSTOP)
            }
        }
    }
    sleep(sleepDelay)
}
