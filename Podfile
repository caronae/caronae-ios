platform :ios, '7.1'

pod 'AFNetworking', '~> 2.0'
pod 'ActionSheetPicker-3.0', '~> 2.0.3'
pod 'TPKeyboardAvoiding', '~> 1.2.10'
pod 'SDCAlertView', '2.5.4'
pod 'SVProgressHUD'
pod 'SDWebImage', '~>3.7'
pod 'SHSPhoneComponent'
pod 'Google/CloudMessaging'
pod 'CRToast', '~> 0.0.7'
pod 'Mantle', '~> 2.0'

link_with 'Caronae'

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
    FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist', 'Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end