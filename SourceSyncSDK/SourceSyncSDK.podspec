
Pod::Spec.new do |spec|
  spec.name         = "SourceSyncSDK"
  spec.version      = "1.0.0"
  spec.summary      = "A framework for handling activation details in iOS apps."
  spec.description  = "SourceSyncSDK provides UI components for activation templates, including headers, previews, and detailed views."
  spec.homepage     = "https://github.com/yourusername/SourceSyncSDK"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Your Name" => "your@email.com" }
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/yourusername/SourceSyncSDK.git", :tag => spec.version }
  spec.source_files = "SourceSyncSDK/Sources/**/*.{h,m,swift}"
  spec.swift_version = "5.7"
end
