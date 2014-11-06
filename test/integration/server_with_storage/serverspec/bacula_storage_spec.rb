require 'serverspec'
# Set backend type
set :backend, :exec
# Don't include Specinfra::Helper::DetectOS

set :path, '/sbin:/usr/sbin:$PATH'

describe "Bacula Storage Daemon" do
  it "is listening on port 9103" do
    expect(port(9103)).to be_listening
  end
  
  it "has a running service of bacula-sd" do
    expect(service("bacula-sd")).to be_running
  end
end
