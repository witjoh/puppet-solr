require 'spec_helper'

describe 'solr::install' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      it { is_expected.to contain_package('default-jdk').with_ensure('present') }
      it { is_expected.to contain_package('jetty').with_ensure('present') }
      it { is_expected.to contain_package('libjetty-extra').with_ensure('present') }
      it { is_expected.to contain_package('wget').with_ensure('present') }
      it { is_expected.to contain_package('curl').with_ensure('present') }
    end
  end
end
