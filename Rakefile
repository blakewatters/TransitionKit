namespace :spec do
  task :prepare do
    system("mkdir -p TransitionKit.xcodeproj/xcshareddata/xcschemes && cp Specs/Schemes/*.xcscheme TransitionKit.xcodeproj/xcshareddata/xcschemes/")
  end
  
  desc "Run the TransitionKit Specs for iOS"
  task :ios => :prepare do
    $ios_success = system("xctool -workspace TransitionKit.xcworkspace -scheme 'iOS Specs' -sdk iphonesimulator build build-tests run-tests -test-sdk iphonesimulator ONLY_ACTIVE_ARCH=NO")
  end
  
  desc "Run the TransitionKit Specs for Mac OS X"
  task :osx => :prepare do
    $osx_success = system("xctool -workspace TransitionKit.xcworkspace -scheme 'OS X Specs' -sdk macosx build build-tests run-tests -test-sdk macosx")
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
