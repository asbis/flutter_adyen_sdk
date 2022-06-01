#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'adyen_flutter'
  s.version          = '0.0.4'
  s.summary          = 'An Adyen Flutter plugin for tha API integration'
  s.description      = <<-DESC
An Adyen Flutter plugin to support the API integration
                       DESC
  s.homepage         = 'http://alexandreroba.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Alexandre Roba' => 'alexandre.roba@arobanet.be' }
  s.source           = { :path => '.' }
  s.swift_version ='5.1'
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Adyen/Card', '~> 4.6.1'
  # s.dependency 'Adyen/Eyncryption'
  s.ios.deployment_target = '11.0'
end

