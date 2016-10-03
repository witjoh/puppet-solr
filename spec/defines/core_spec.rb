require 'spec_helper'

describe 'solr::core', :type => :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      context 'default behaviour' do
        let(:title) { 'default' }
        it do
          is_expected.to contain_file('/usr/share/solr/default').with(
            'ensure'  => 'directory',
            'owner'   => 'jetty',
            'group'   => 'jetty',
            'require' => 'File[/usr/share/solr]',
          )
        end
        it do 
          is_expected.to contain_file('/usr/share/solr/default/conf').with(
            'ensure'  => 'directory',
            'recurse' => 'true',
            'source'  => 'puppet:///modules/solr/conf',
            'require' => 'File[/usr/share/solr/default]',
          )
        end 
        it do
          is_expected.to contain_file('/var/lib/solr/default').with(
            'ensure'  => 'directory',
            'owner'   => 'jetty',
            'group'   => 'jetty',
            'require' => 'File[/usr/share/solr/default/conf]',
          )
        end
      end
      context 'link to a custom location' do
        let (:title) { 'linked' }
        let (:params) do 
          {
            :config_type   => 'link',
            :config_source => '/vagrant/custom_solr_test', 
          }
          it do
            is_expected.to contain_file('/usr/share/solr/linked').with(
              'ensure'  => 'directory',
              'owner'   => 'jetty',
              'group'   => 'jetty',
              'require' => 'File[/usr/share/solr]',
            )
          end
          it do
            is_expected.to contain_file('/usr/share/solr/linked/conf').with(
            'ensure'  => 'link',
            'owner'   => 'jetty',
            'group'   => 'jetty',
            'target'  => '/vagrant/custom_solr_test',
            'require' => 'File[/usr/share/solr/linked]',
            )
          end
        end
      end
    end
  end
end
