Pod::Spec.new do |s|
  s.name     = 'AppProgressCore'
  s.version  = '1.0.5'
  s.ios.deployment_target = '9.0'
  s.license  =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'Appleらしいローディングができます。App Extension用です。'
  s.homepage = 'https://github.com/hideyukitone/AppProgress'
  s.authors   = { 'hideyuki okuni' => 'hideyukitone@gmail.com' }
  s.source   = { :git => 'https://github.com/hideyukitone/AppProgress.git', :tag => 'v1.0.5' }
  s.source_files = 'AppProgress/*.{swift}', 'AppProgress/View/*.{swift}', 'AppProgress/Protocol/*.{swift}', 'AppProgress/Enum/*.{swift}'
  s.requires_arc = true
  s.swift_version = "4.1"
end
