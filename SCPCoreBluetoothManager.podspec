Pod::Spec.new do |s|
  s.name             = "SCPCoreBluetoothManager"
  s.version          = "1.0.2"
  s.summary          = "Block based wrapper around the Core Bluetooth framework."
  s.description      = <<-DESC
                        This is only v1.0 and only includes the Central Manager part, the Peripheral Manager part is still in development.
                       DESC
  s.homepage         = "https://github.com/steprescott/SCPCoreBluetoothManager"
  s.license          = 'MIT'
  s.author           = { "Ste Prescott" => "github@ste.me" }
  s.source           = { :git => "https://github.com/steprescott/SCPCoreBluetoothManager.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ste_prescott'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Classes/**/*.h'

  s.frameworks = 'CoreBluetooth'
  s.dependency 'SVProgressHUD'
  
end
