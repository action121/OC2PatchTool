
$app_macos_deployment_target = Gem::Version.new('12.0')

platform :macos, $app_macos_deployment_target.to_s()

target 'OC2PatchTool' do

  use_frameworks!
  
  pod 'SSZipArchive'
  pod 'Masonry'
  
end

def custom_log(content)
    puts "\033[36m ==> " + content + " \033[0m \n"
end

def hook_main_project
    # xcode15编译问题
    custom_log("💡💡 适配xcode15")
    require 'xcodeproj'
    project_path = './OC2PatchTool.xcodeproj'
    project = Xcodeproj::Project.open(project_path)
    project.targets.each do |target|
        if target.name == 'OC2PatchTool'
            target.build_configurations.each do |config|
                if  Gem::Version.new($xcode_selected_version) >= Gem::Version.new('15.0')
                    config.build_settings['OTHER_LDFLAGS'] = '$(inherited) -ld_classic'
                else
                    config.build_settings['OTHER_LDFLAGS'] = '$(inherited)'
                end
            end
        end
    end
    project.save
end

def post_install_hook
  
  post_install do |installer|
    
    
      # pod版本1.13.0后对xcode15做了适配调整，这里适配低版本pod & xcode15的组合使用
      if $current_pod_version < Gem::Version.new('1.13.0') and Gem::Version.new($xcode_selected_version) >= Gem::Version.new('15.0')
        custom_log("💡💡 适配低版本pod & xcode15的组合使用")
        installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
            if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
              xcconfig_path = config.base_configuration_reference.real_path
              IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
            end
          end
        end
      end
      
      installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['CODE_SIGN_IDENTITY'] = ''
          config.build_settings['VALID_ARCHS'] = 'x86_64'
          pod_macos_deployment_target = Gem::Version.new(config.build_settings['MACOSX_DEPLOYMENT_TARGET'])
          if pod_macos_deployment_target <= $app_macos_deployment_target
              config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = $app_macos_deployment_target.to_s()
          end
        end
      end
  
  end
  
end

$current_pod_version = Gem::Version.new(`pod --version`)
custom_log('pod version: ' + $current_pod_version.to_s())

$xcode_selected_version = `xcodebuild -version | awk '/Xcode/ {print $2}' | tr -d ' \n'`
custom_log('xcode_selected_version: ' + $xcode_selected_version)

hook_main_project

post_install_hook
