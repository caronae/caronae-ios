platform :ios, '9.0'

abstract_target 'caronae-ios' do
    use_frameworks!
    inhibit_all_warnings!
    
    pod 'AFNetworking', '~> 3.2'
    pod 'ActionSheetPicker-3.0', '~> 2.3.0'
    pod 'TPKeyboardAvoiding', '~> 1.3.2'
    pod 'SDCAlertView', '2.5.4'
    pod 'SVProgressHUD'
    pod 'SDWebImage', '~> 4.3'
    pod 'InputMask'
    pod 'SwiftMessages'
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    pod 'RealmSwift', '~> 3.5'
    pod 'ObjectMapper', '~> 3.1'
    pod 'ObjectMapper+Realm', '~> 0.5'
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    pod 'JSQMessagesViewController', :git => 'https://github.com/caronae/JSQMessagesViewController.git', :branch => 'issue-1864'
    pod 'MIBadgeButton-Swift', :git => 'https://github.com/mustafaibrahim989/MIBadgeButton-Swift.git', :branch => 'master'
    pod 'UIScrollView-InfiniteScroll'
    pod 'SimpleKeychain', '~> 0.8'
    pod 'YPImagePicker', '~> 3.0'
    pod 'SKPhotoBrowser', '~> 5.1'
    target 'Caronae'
    target 'Caronae Dev'

    target 'Caronae UITests' do
        pod 'SimulatorStatusMagic', :configurations => ['Tests']
    end
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-caronae-ios-Caronae/Pods-caronae-ios-Caronae-acknowledgements.plist', 'Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

class ::Pod::Generator::Acknowledgements
    def header_title
        "Agradecimentos"
    end

    def header_text
        "Este app faz uso das seguintes bibiliotecas de terceiros, cujas licenças encontram-se abaixo:"
    end
end
