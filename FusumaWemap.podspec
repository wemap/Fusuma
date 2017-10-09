Pod::Spec.new do |s|
  s.name             = "FusumaWemap"
  s.version          = "2.0.0"
  s.summary          = "Instagram-like photo browser with a few line of code written in Swift. Wemap SAS rewrited and updated"
  s.homepage         = "https://github.com/wemap/Fusuma"
  s.license          = 'MIT'
  s.author           = { "ytakzk" => "shyss.ak@gmail.com" }
  s.source           = { :git => "https://github.com/wemap/Fusuma.git",
  #:tag => s.version.to_s
  }
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.source_files = 'Sources/**/*.swift'
  s.resources = 'Sources/Resources/*'
end
