#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
require 'yaml'
pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
libraryVersion = pubspec['version'].gsub('+', '-')
pusherLibraryVersion = '1.6.3'

Pod::Spec.new do |s|
  s.name             = 'flutter_pusher'
  s.version          = libraryVersion
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Genert Org' => 'genert.org@indoor.solutions' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'libPusher', pusherLibraryVersion

  s.ios.deployment_target = '8.0'

s.prepare_command = <<-CMD
    echo // Generated file, do not edit > Classes/UserAgent.h
    echo "#define LIBRARY_VERSION @\\"#{libraryVersion}\\"" >> Classes/UserAgent.h
    echo "#define LIBRARY_NAME @\\"flutter_pusher\\"" >> Classes/UserAgent.h
    echo "#define PUSHER_LIBRARY_VERSION @\\"#{pusherLibraryVersion}\\"" >> Classes/UserAgent.h
  CMD
end

