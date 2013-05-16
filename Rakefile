namespace :spec do
  desc "Run the TransitionKit Specs for iOS"
  task :ios do
    $ios_success = system("xctool -workspace TransitionKit.xcworkspace -scheme 'iOS Specs' test -test-sdk iphonesimulator")
  end
  
  desc "Run the TransitionKit Specs for Mac OS X"
  task :osx do
    $osx_success = system("xctool -workspace TransitionKit.xcworkspace -scheme 'OS X Specs' test -test-sdk macosx -sdk macosx")
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

task :default => 'test'
