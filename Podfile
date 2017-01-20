platform :ios, '8.0'

target 'Caronae' do
    use_frameworks!
    
    pod 'AFNetworking', '~> 2.6.3'
    pod 'ActionSheetPicker-3.0', '~> 2.0.5'
    pod 'TPKeyboardAvoiding', '~> 1.2.11'
    pod 'SDCAlertView', '2.5.4'
    pod 'SVProgressHUD'
    pod 'SDWebImage', '~>3.8.2'
    pod 'SHSPhoneComponent'
    pod 'CRToast', '~> 0.0.7'
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    pod 'RealmSwift', '~> 2.1'
    pod 'ObjectMapper', '~> 2.2'
    pod 'ObjectMapper+Realm', '~> 0.2'
    pod 'UITextView+Placeholder', '~> 1.2'
    pod 'Firebase/Messaging'
    pod 'JSQMessagesViewController'
    pod "MIBadgeButton-Swift", :git => 'https://github.com/mustafaibrahim989/MIBadgeButton-Swift.git', :branch => 'master'
    
    target 'CaronaeTests' do
        inherit! :search_paths
    end

    class ::Pod::Generator::Acknowledgements
        def header_title
            "Agradecimentos"
        end

        def header_text
            "Este app faz uso das seguintes bibiliotecas de terceiros:"
        end
    end

    post_install do | installer |
        require 'fileutils'
        FileUtils.cp_r('Pods/Target Support Files/Pods-Caronae/Pods-Caronae-acknowledgements.plist', 'Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    end
end
