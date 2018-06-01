/*
 App Environment
 
 Intended to function as the gateway to other singleton-live services
 Creates opportunity to mock service dependencies during unit tests
 */

class AppEnv {
    
    // static vars
    static fileprivate(set) var current: AppEnv!
    static var environments: [AppEnv] = []
    
    // instance structure
    var targetApis: TargetApis
    var operatingSystem: OperatingSystem
    var debugLevel: DebugLevel

    // instance managers
    var toDoItemsManager: ResourceManager<ToDoItem>!

    // static methods
    static func pushEnvironment(_ env: AppEnv) {
        AppEnv.environments.append(env)
        AppEnv.current = env
    }
    
    static func popEnvironment() {
        AppEnv.environments.removeLast()
        AppEnv.current = AppEnv.environments.last
    }
    
    // instance methods
    public init() {
        targetApis = .staging
        operatingSystem = .iOS
        debugLevel = DebugLevel.off
    }
    
}

public enum TargetApis {
    case staging
    case production
}

public enum OperatingSystem {
    case iOS
    case tvos
}

public enum DebugLevel {
    case off
    case debug
}
