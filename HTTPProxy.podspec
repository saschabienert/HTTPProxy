Pod::Spec.new do |spec|
  spec.name          = 'HTTPProxy'
  spec.version       = '0.0.7'
  spec.license       = { :type => 'MIT' }
  spec.homepage      = 'https://github.com/rafaelleao/HTTPProxy'
  spec.authors       = { 'Rafael Leão' => 'rafaeldeleao@gmail.com' }
  spec.source        = { :git => 'https://github.com/rafaelleao/HTTPProxy.git', :tag => spec.version }
  spec.summary       = 'A network debugging tool for iOS'
  spec.swift_version = '5.0'
  spec.platform      = :ios, '9.0'
  spec.source_files  = 'HTTPProxy/Library/**/*.swift'
  spec.resources     = ['HTTPProxy/Library/**/*.{storyboard,xib,js,css}']
end
