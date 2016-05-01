platform :ios, '8.0'
use_frameworks!

PROJECT_NAME = 'MyGithubSearch'
TEST_TARGET = 'MyGithubSearchEarlGrey'
SCHEME_FILE = 'MyGithubSearch.xcscheme'

pod 'AFNetworking', '~> 3.0'

target 'MyGithubSearch' do

end

target 'MyGithubSearchTests' do
  pod 'OHHTTPStubs', '~> 4.1.0'
end

target 'MyGithubSearchEarlGrey' do
  pod 'EarlGrey'
end

target 'MyGithubSearchUITests' do

end

post_install do |installer|
  load("configure_earlgrey_pods.rb")
  configure_for_earlgrey(installer, PROJECT_NAME, TEST_TARGET, SCHEME_FILE)
end
