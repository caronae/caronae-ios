fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios prepare_build
```
fastlane ios prepare_build
```
Prepare dependencies for building app
### ios build
```
fastlane ios build
```
Build app
### ios beta
```
fastlane ios beta
```
Deploy a new build to TestFlight
### ios deploy
```
fastlane ios deploy
```
Deploy a new version to the App Store
### ios update_signing
```
fastlane ios update_signing
```
Update and install all certificates and provisioning profiles
### ios install_signing
```
fastlane ios install_signing
```
Install all certificates and provisioning profiles
### ios encrypt_keys
```
fastlane ios encrypt_keys
```
Encrypt sensitive keys using AWS KMS
### ios decrypt_keys
```
fastlane ios decrypt_keys
```
Decrypt sensitive keys using AWS KMS
### ios update_build_number
```
fastlane ios update_build_number
```
Update and tag the version/build
### ios take_screenshots
```
fastlane ios take_screenshots
```
Take and frame screenshots of the app

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
