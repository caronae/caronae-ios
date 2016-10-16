fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios commit_build_bump
```
fastlane ios commit_build_bump
```
Commit the version/build number bump
### ios tag
```
fastlane ios tag
```
Add tag with the current version and build number
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios deploy
```
fastlane ios deploy
```
Deploy a new version to the App Store
### ios match_everything
```
fastlane ios match_everything
```
Sync all certificates and provisioning profiles

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).
