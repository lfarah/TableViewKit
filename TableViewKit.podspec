Pod::Spec.new do |s|
  s.name                    = "TableViewKit"
  s.version                 = "0.9.0"
  s.summary                 = "Empowering UITableView with painless multi-type cell support and build-in automatic state transition animations"
  s.homepage                = "http://www.edreamsodigeo.com/"
  s.license                 = "MIT"
  s.author                  = "TableViewKit Contributors"
  s.ios.deployment_target   = "8.0"
  s.source                  = { :git => 'https://github.com/odigeoteam/TableViewKit.git', :tag => "v#{s.version}" }
  s.source_files  				  = "TableViewKit/**/*.swift"
  s.framework  							= "UIKit", "Foundation"
  s.requires_arc 						= true
end
