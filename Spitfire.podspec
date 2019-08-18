Pod::Spec.new do |s|
s.name             = 'Spitfire'
s.version          = '2.0'
s.summary          = 'A fairly basic utility for taking an array of UIImages and producing a MOV video file.'
s.description      = <<-DESC
Spitfire will take an array of one or more UIImages, and produce a video file from them. It provides a nice range of error messages to assist in troubleshooting, and is designed
such that it should handle most common scenarios without any problems.
DESC
s.author = { "Sean McNeil" => "mcneilsean@noname.com" }
s.homepage         = 'https://github.com/seanmcneil/Spitfire'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.source           = { :git => 'https://github.com/seanmcneil/Spitfire.git', :tag => s.version.to_s }
s.swift_versions   = '5.0'
s.ios.deployment_target = '11.0'

s.source_files = 'Spitfire/Classes/**/*'
end
