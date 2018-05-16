
Pod::Spec.new do |s|

  s.name         = "UNOBehaviorMonitor"
  s.version      = "0.0.1"
  s.summary      = "A short description of UNOBehaviorMonitor."

  s.homepage     = "http://EXAMPLE/UNOBehaviorMonitor"

  s.license      = "MIT"

  s.author    = "jinmintong"

  s.ios.deployment_target = "7.0"

  s.source       = { :path => '.' }

#  s.exclude_files = "Classes/Exclude"

  s.public_header_files = "UNOBehaviorMonitor/vender/Api/*.h"

  s.subspec 'core' do |ss|
  ss.source_files = 'UNOBehaviorMonitor/vender/Core/*.{h,m}'
  ss.dependency "UNOAspect"
  
  end
	
  s.subspec 'Api' do |ss|
  ss.source_files = 'UNOBehaviorMonitor/vender/Api/*.{h,m}'
  end

  s.subspec 'Util' do |ss|
  ss.source_files = 'UNOBehaviorMonitor/vender/Util/*.{h,m}'
  end

end
