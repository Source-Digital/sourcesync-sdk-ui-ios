Pod::Spec.new do |spec|
  spec.name         = "SourceSyncSDK"
  spec.version      = "0.3.16"
  spec.summary      = "A framework for handling activation details in iOS apps."
  spec.description  = <<-DESC
                      SourceSyncSDK provides UI components for activation templates, 
                      including headers, previews, and detailed views. This SDK helps 
                      developers integrate Source Digital's platform features into their 
                      iOS applications with DivKit-powered dynamic UI components.
                      DESC
  
  spec.homepage     = "https://github.com/Source-Digital/sourcesync-sdk-ui-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Source Digital" => "dev@sourcedigital.net" }
  
  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.7"
  
  spec.source = { 
    :git => "https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git", 
    :tag => "#{spec.version}" 
  }
  
  # Source files - flexible path for both workspace and external use
  spec.source_files = "Sources/**/*.{h,m,swift}", "SourceSyncSDK/Sources/**/*.{h,m,swift}"
  spec.public_header_files = "Sources/**/SourceSyncSDK.h", "SourceSyncSDK/Sources/**/SourceSyncSDK.h"
  
  # Resources if any
  spec.resources = "Sources/**/Resources/**/*", "SourceSyncSDK/Sources/**/Resources/**/*"
  
  # Exclude files
  spec.exclude_files = [
    "Package.swift",
    "**/Package.swift", 
    "TestApp/**/*",
    "Tests/**/*",
    "**/Tests/**/*",
    "Example/**/*"
  ]
  
  # DivKit dependencies
  spec.dependency "DivKit", "~> 32.1.0"
  spec.dependency "DivKitExtensions", "~> 32.1.0"
  
  spec.frameworks = "UIKit", "Foundation"
  
  # Universal build configuration
  spec.pod_target_xcconfig = { 
    'ARCHS' => '$(ARCHS_STANDARD)',
    'VALID_ARCHS' => 'arm64 x86_64',
    'ONLY_ACTIVE_ARCH' => 'NO',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => '',
    'SWIFT_VERSION' => '5.7',
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_MODULES' => 'YES',
    'SWIFT_COMPILATION_MODE' => 'wholemodule',
    'IPHONEOS_DEPLOYMENT_TARGET' => '13.0'
  }
  
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => '',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited)'
  }
  
  spec.requires_arc = true
  spec.module_name = "SourceSyncSDK"
end
