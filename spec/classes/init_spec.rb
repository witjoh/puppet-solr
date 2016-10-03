require 'spec_helper'

describe 'solr' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        context "where params are not passed (default case)" do
          it { is_expected.to contain_class('solr::params') }
          it { is_expected.to contain_class('solr::install') }
          it do 
            is_expected.to contain_class('solr::config').with(
              'cores'     => ['default'],
              'version'   => '4.7.2',
              'mirror'    => 'http://www.us.apache.org/dist/lucene/solr',
              'dist_root' => '/tmp',
            )
          end
          it { is_expected.to contain_class('solr::service') }
        end
        context "where params are passed" do
          let(:params) do 
            { 
              :cores     => ['dev', 'prod'],
              :version   => '5.6.2',
              :mirror    => 'http://some-random-site.us',
              :dist_root => '/opt/tmpdata',
            }
          end
          it { is_expected.to contain_class('solr::params') }
          it { is_expected.to contain_class('solr::install') }
          it do 
            is_expected.to contain_class('solr::config').with(
              'cores'     => ['dev', 'prod'],
              'version'   => '5.6.2',
              'mirror'    => 'http://some-random-site.us',
              'dist_root' => '/opt/tmpdata'
            )
          end
          it { is_expected.to contain_class('solr::service') }
        end
      end
    end
  end
end
