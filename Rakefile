def build_and_run_tests(command, sdk_name)
  %w{build-tests test}.each do |action|
    sdk = (action == 'test') ? "-test-sdk #{sdk_name}" : "-sdk #{sdk_name}"
    cmd = command % { action: action, sdk: sdk }
    puts "Executing `#{cmd}`..."
    return unless system(cmd)
  end  
end

namespace :spec do
  task :prepare do
    system("mkdir -p TransitionKit.xcodeproj/xcshareddata/xcschemes && cp Specs/Schemes/*.xcscheme TransitionKit.xcodeproj/xcshareddata/xcschemes/")
  end
  
  desc "Run the TransitionKit Specs for iOS"
  task :ios => :prepare do
    $ios_success = build_and_run_tests("xctool -workspace TransitionKit.xcworkspace -scheme 'iOS Specs' %{action} %{sdk} ONLY_ACTIVE_ARCH=NO", :iphonesimulator)
  end
  
  desc "Run the TransitionKit Specs for Mac OS X"
  task :osx => :prepare do
    $osx_success = build_and_run_tests("xctool -workspace TransitionKit.xcworkspace -scheme 'OS X Specs' %{action} %{sdk}", :macosx)
  end
end

desc "Run the TransitionKit Specs for iOS & Mac OS X"
task :spec => ['spec:ios', 'spec:osx'] do
  puts "\033[0;31m!! iOS specs failed" unless $ios_success
  puts "\033[0;31m!! OS X specs failed" unless $osx_success
  if $ios_success && $osx_success
    puts "\033[0;32m** All tests executed successfully"
  else
    exit(-1)
  end
end

task :default => 'spec'
