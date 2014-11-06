require 'serverspec'
# Set backend type
set :backend, :exec
# Don't include Specinfra::Helper::DetectOS

set :path, '/sbin:/usr/sbin:$PATH'


describe "Bacula Client Daemon" do

  it "is listening on port 9102" do
    expect(port(9102)).to be_listening
  end

  it "has a running service of bacula-fd" do
    expect(service("bacula-fd")).to be_running
  end

end
