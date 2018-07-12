import Foundation

protocol Dispatcher {
    func dispatch(block: @escaping ()->Void)
}

class MainAsyncDispatcher: Dispatcher {
    
    func dispatch(block: @escaping ()->Void) {
        DispatchQueue.main.async {
            block()
        }
    }
}

class SyncDispatcher: Dispatcher {
    
    func dispatch(block: @escaping ()->Void) {
        block()
    }
}
