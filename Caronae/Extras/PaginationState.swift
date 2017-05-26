import Foundation

struct PaginationState {
    var directionGoing = true
    private var nextPageGoing = 1
    private var nextPageReturning = 1
    private var lastPageGoing = 1
    private var lastPageReturning = 1
    
    private(set) var nextPage: Int {
        get { return directionGoing ? nextPageGoing : nextPageReturning }
        set { directionGoing ? (nextPageGoing = newValue) : (nextPageReturning = newValue) }
    }
    
    var lastPage: Int {
        get { return directionGoing ? lastPageGoing : lastPageReturning }
        set { directionGoing ? (lastPageGoing = newValue) : (lastPageReturning = newValue) }
    }
    
    var hasNextPage: Bool {
        return nextPage <= lastPage
    }
    
    mutating func incrementPage() {
        nextPage += 1
    }
}
