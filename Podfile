
platform :ios, '10.0'

target 'RxSwift-Novel' do
   use_frameworks!
   
   pod 'RxSwift', '~> 5'
   pod 'RxCocoa', '~> 5'
   pod 'RxDataSources', '~> 4.0'
   pod 'Moya/RxSwift', '~> 14.0'
   pod 'Kingfisher'
   pod 'URLNavigator'
   pod 'Kanna', '~> 5.2.2'
   pod 'HandyJSON', '~> 5.0.1'
   pod 'SwiftyJSON', '~> 5.0.0'
   pod 'NVActivityIndicatorView'

end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'RxSwift'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
        end
      end
    end
  end
end
