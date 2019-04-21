Pod::Spec.new do |s|
  s.name        = 'Cria'
  s.module_name = 'Cria'
  s.version     = '1.1.0'
  s.summary     = 'Cria is an elegant HTTP requests framework for Swift with ❤️ and Alamofire + Promise ☁️.'

  s.homepage    = 'https://github.com/Meniny/Cria'
  s.license     = { type: 'MIT', file: 'LICENSE.md' }
  s.authors     = { 'Elias Abel' => 'admin@meniny.cn' }
  s.social_media_url = 'https://meniny.cn/'

  s.ios.deployment_target     = '8.0'
  s.osx.deployment_target     = '10.10'
  s.tvos.deployment_target    = '9.0'

  s.requires_arc        = true
  s.source              = { git: 'https://github.com/Meniny/Cria.git', tag: s.version.to_s }

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5' }
  s.swift_version       = '5'

  s.dependency 'Oath'
  s.dependency 'Alamofire', '~> 4.7'

  s.default_subspecs = 'Core'

  s.subspec 'Core' do |sp|
    sp.source_files  = 'Cria/Core/**/*.swift'
  end
end
