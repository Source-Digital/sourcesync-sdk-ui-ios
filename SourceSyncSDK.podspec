Pod::Spec.new do |spec|
  spec.name         = "SourceSyncSDK"
  spec.version      = "0.3.12"
  spec.summary      = "A framework for handling activation details in iOS apps."
  spec.description  = "SourceSyncSDK provides UI components for activation templates, including headers, previews, and detailed views. This SDK helps developers integrate Source Digital's platform features into their iOS applications."
  spec.homepage     = "https://github.com/Source-Digital/sourcesync-sdk-ui-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Source Digital" => "dev@sourcedigital.net" }
  
  # Define supported platforms (iOS only now)
  spec.ios.deployment_target = "13.0"
  
  spec.source       = { :git => "https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git", 
                        :tag => "#{spec.version}" }

  # Verify these paths match your actual project structure
  spec.source_files = "SourceSyncSDK/Sources/**/*.{h,m,swift}"

  # Explicitly exclude Package.swift
  spec.exclude_files = "SourceSyncSDK/**/Package.swift", "Example/**/*", "Tests/**/*"
  
  # DivKit dependencies
  spec.dependency "DivKit", "~> 31.14.0"
  spec.dependency "DivKitExtensions", "~> 31.14.0"

  spec.pod_target_xcconfig = { 
  # Explicitly exclude x86_64 for simulator builds
  'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
  # Only include architectures that DivKit supports
  'VALID_ARCHS' => 'arm64 arm64e',
  'SUPPORTS_MACCATALYST' => 'NO'
  }

 # This ensures consumers of your pod don't build for x86_64 simulator
  spec.user_target_xcconfig = {
  'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }

  # iOS framework
  spec.ios.framework = "UIKit"

  spec.swift_version = "5.7"
  spec.requires_arc = true
  
  # Add build settings to ensure multi-architecture support
  spec.ios.pod_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'NO' }

  spec.module_name = "SourceSyncSDK"
end