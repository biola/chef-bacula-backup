require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe "Bacula Client Daemon" do

  it "is listening on port 9102" do
    expect(port(9102)).to be_listening
  end

  it "has a running service of bacula-fd" do
    expect(service("bacula-fd")).to be_running
  end

end
