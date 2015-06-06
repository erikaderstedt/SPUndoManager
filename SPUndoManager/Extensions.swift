import Foundation

extension Array {
    func atIndex(index: Int) -> T? {
        if index >= 0 && index < count {
            return self[index]
        }
        return nil
    }
    
    func each(function: (element: T) -> Void) {
        for e in self {
            function(element: e)
        }
    }
    
    func eachForwards(function: (element: T) -> Void) {
        for i in 0 ..< self.count {
            function(element: self[i])
        }
    }
    
    func eachBackwards(function: (element: T) -> Void) {
        for i in lazy(0..<self.count).reverse() {
            function(element: self[i])
        }
    }
}