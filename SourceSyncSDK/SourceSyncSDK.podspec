Pod::Spec.new do |spec|
  spec.name         = "SourceSyncSDK"
  spec.version      = "0.3.22"
  spec.summary      = "A framework for handling activation details in iOS apps."
  spec.homepage     = "https://github.com/Source-Digital/sourcesync-sdk-ui-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE.md" }
  spec.author       = { "Source Digital" => "dev@sourcedigital.net" }
  
  # Platform support
  spec.ios.deployment_target = "14.0"
  
  spec.swift_version = "5.7"
  spec.source = { :git => "https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git", :tag => "#{spec.version}" }
  
  # Source files
  spec.source_files = "Sources/**/*.{h,m,swift}", "SourceSyncSDK/Sources/**/*.{h,m,swift}"
  spec.exclude_files = "Package.swift", "TestApp/**/*", "Tests/**/*", "Example/**/*"
  
  # Dependencies
  spec.dependency "DivKit", "~> 31.13.0"
  spec.dependency "DivKitExtensions", "~> 31.13.0"
  spec.frameworks = "UIKit", "Foundation"
  
  # Platform-specific configurations
  spec.ios.pod_target_xcconfig = { 
    'ARCHS' => '$(ARCHS_STANDARD)',
    'VALID_ARCHS' => 'arm64 x86_64 arm64e',
    'EXCLUDED_ARCHS' => '',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'NO',
    'SWIFT_VERSION' => '5.7',
    'ENABLE_BITCODE' => 'NO'
  }
  
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS' => '',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited)'
  }
  
  spec.requires_arc = true
  spec.module_name = "SourceSyncSDK"
end
