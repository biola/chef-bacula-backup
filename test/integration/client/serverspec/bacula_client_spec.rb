require 'serverspec'
# Set backend type
set :backend, :exec
# Don't include Specinfra::Helper::DetectOS

set :path, '/sbin:/usr/sbin:$PATH'


describe 'Bacula Client Daemon' do

  it 'is listening on port 9102' do
    expect(port(9102)).to be_listening
  end

  if os[:family] == 'redhat'
    it 'has a running service of bareos-fd' do
      expect(service('bareos-fd')).to be_running
    end

    describe file('/etc/bareos/bareos-fd.conf') do
      it { should be_file }
    end
    ['lzo-2.06', 'libfastlz-0.1', 'bareos-common', 'bareos-filedaemon'].each do |pkg|
      describe package(pkg) do
	it { should be_installed }
      end
    end

  elsif ['debian', 'ubuntu'].include?(os[:family])
    it 'has a running service of bacula-fd' do
      expect(service('bacula-fd')).to be_running
    end
  end

end
