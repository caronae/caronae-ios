fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

<table width="100%" >
<tr>
<th width="33%"><a href="http://brew.sh">Homebrew</a></th>
<th width="33%">Installer Script</th>
<th width="33%">RubyGems</th>
</tr>
<tr>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS or Linux with Ruby 2.0.0 or above</td>
</tr>
<tr>
<td width="33%"><code>brew cask install fastlane</code></td>
<td width="33%"><a href="https://download.fastlane.tools">Download the zip file</a>. Then double click on the <code>install</code> script (or run it in a terminal window).</td>
<td width="33%"><code>sudo gem install fastlane -NV</code></td>
</tr>
</table>

# Available Actions
## iOS
### ios build
```
fastlane ios build
```
Submit a new build to TestFlight
### ios beta
```
fastlane ios beta
```
Submit a new build to TestFlight
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

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
