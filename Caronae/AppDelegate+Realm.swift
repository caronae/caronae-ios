import RealmSwift

extension AppDelegate {
    func configureRealm() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // swiftlint:disable:previous unused_closure_parameter
                // We haven’t migrated anything yet
                
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        NSLog("Realm file: \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
}
