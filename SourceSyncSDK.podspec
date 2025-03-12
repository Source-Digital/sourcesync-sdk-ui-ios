Pod::Spec.new do |spec|
  spec.name         = "SourceSyncSDK"
  spec.version      = "0.2.5"
  spec.summary      = "A framework for handling activation details in iOS and tvOS apps."
  spec.description  = "SourceSyncSDK provides UI components for activation templates, including headers, previews, and detailed views. This SDK helps developers integrate Source Digital's platform features into their iOS and tvOS applications."
  spec.homepage     = "https://github.com/Source-Digital/sourcesync-sdk-ui-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Source Digital" => "dev@sourcedigital.net" }
  
  # Define supported platforms
  spec.ios.deployment_target = "13.0"
  spec.tvos.deployment_target = "13.0"
  
  spec.source       = { :git => "https://github.com/Source-Digital/sourcesync-sdk-ui-ios.git", 
                        :tag => "#{spec.version}" }

  
  # Verify these paths match your actual project structure
  spec.source_files = "SourceSyncSDK/Sources/**/*.{h,m,swift}"

  # Explicitly exclude Package.swift
  spec.exclude_files = "SourceSyncSDK/**/Package.swift", "Example/**/*", "Tests/**/*"
  
  spec.pod_target_xcconfig = { 
  'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited) TVOS_BUILD'
  }

  # Platform-specific frameworks
  spec.ios.framework = "UIKit"
  spec.tvos.framework = "UIKit", "TVUIKit"

  spec.swift_version = "5.7"
  spec.requires_arc = true
  
end
