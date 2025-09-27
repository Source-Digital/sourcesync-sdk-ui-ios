Pod::Spec.new do |spec|
  spec.name         = "SourceSyncSDK"
  spec.version      = "0.3.25"
  spec.summary      = "A framework for handling activation details in iOS apps."
  spec.homepage     = "https://github.com/Source-Digital/sourcesync-sdk-ui-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE.md" }
  spec.author       = { "Source Digital" => "dev@sourcedigital.net" }
  
  spec.ios.deployment_target = "17.0"
  spec.swift_version = "5.9"
  spec.source = { :git => "https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git", :tag => "#{spec.version}" }
  
  # Source files
  spec.source_files = "Sources/**/*.{h,m,swift}", "SourceSyncSDK/Sources/**/*.{h,m,swift}"
  spec.exclude_files = "Package.swift", "TestApp/**/*", "Tests/**/*", "Example/**/*"
  
  # Dependencies
  spec.dependency "DivKit", "~> 31.13.0"
  spec.dependency "DivKitExtensions", "~> 31.13.0"
  spec.frameworks = "UIKit", "Foundation"
  
  # Universal binary support
  spec.pod_target_xcconfig = { 
    'ARCHS' => '$(ARCHS_STANDARD)',
    'VALID_ARCHS' => 'arm64 x86_64 arm64e',
    'EXCLUDED_ARCHS' => '',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'NO',
    'SWIFT_VERSION' => '5.9',
    'ENABLE_BITCODE' => 'NO'
  }
  
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS' => '',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited)'
  }
  
  spec.requires_arc = true
  spec.module_name = "SourceSyncSDK"
end
