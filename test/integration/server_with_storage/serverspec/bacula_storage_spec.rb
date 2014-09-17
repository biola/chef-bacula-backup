require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe "Bacula Storage Daemon" do

  it "is listening on port 9103" do
    expect(port(9103)).to be_listening
  end

  it "has a running service of bacula-sd" do
    expect(service("bacula-sd")).to be_running
  end

end

