require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

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
