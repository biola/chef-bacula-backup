require 'serverspec'
# Set backend type
set :backend, :exec
# Don't include Specinfra::Helper::DetectOS

set :path, '/sbin:/usr/sbin:$PATH'


describe "Bacula Director Daemon" do
  it "is listening on port 9101" do
    expect(port(9101)).to be_listening
  end
  
  it "starts at boot" do
    expect(service("bacula-director")).to be_enabled
  end
  
  it "is running" do
    expect(process("bacula-dir")).to be_running
  end
end
