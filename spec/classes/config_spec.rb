require 'spec_helper'

describe 'solr::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      context "when params aren't passed - default case" do
        it do 
          is_expected.to contain_file('/etc/default/jetty').with(
            'ensure'  =>    'file',
            'source'  =>    'puppet:///modules/solr/jetty-default',
            'require' =>    'Package[jetty]',
          )
        end
        it do 
          is_expected.to contain_file('/usr/share/solr').with(
            'ensure'  =>  'directory',
            'owner'   =>  'jetty',
            'group'   =>  'jetty',
            'require' =>  'Package[jetty]',
          )
        end 
        it do 
          is_expected.to contain_file('/var/lib/solr').with(
            'ensure'  => 'directory',
            'owner'   => 'jetty',
            'group'   => 'jetty',
            'mode'    => '0700',
            'require' => 'Package[jetty]',
          )
        end
        it do
          is_expected.to contain_file('/usr/share/solr/solr.xml').with(
            'ensure'  => 'file',
            'owner'   => 'jetty',
            'group'   => 'jetty',
            'content' => /\/var\/lib\/solr\/default/,
            'require' => 'File[/etc/default/jetty]',
          )
        end
        it do
          is_expected.to contain_file('/usr/share/jetty/webapps/solr').with(
            'ensure'  => 'link',
            'target'  => '/usr/share/solr',
            'require' => 'File[/usr/share/solr/solr.xml]',
          )
        end 
        it do
          is_expected.to contain_exec('solr-download').with(
            'command' =>  'wget http://www.us.apache.org/dist/lucene/solr/4.7.2/solr-4.7.2.tgz',
            'cwd'     =>  '/tmp',
            'creates' =>  '/tmp/solr-4.7.2.tgz',
            'onlyif'  =>  'test ! -d /usr/share/solr/WEB-INF && test ! -f /tmp/solr-4.7.2.tgz',
            'timeout' =>  0,
            'require' =>  'File[/usr/share/solr]'
          )
        end
        it do
          is_expected.to contain_exec('extract-solr').with(
            'path'    =>  '["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin"]',
            'command' =>  'tar xvf solr-4.7.2.tgz',
            'cwd'     =>  '/tmp',
            'onlyif'  =>  'test -f /tmp/solr-4.7.2.tgz && test ! -d /tmp/solr-4.7.2',
            'require' =>  'Exec[solr-download]',
          )
        end
        it do
          is_expected.to contain_exec('copy-solr').with(
            'path'    =>  '["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin"]',
            'command' =>  "jar xvf /tmp/solr-4.7.2/dist/solr-4.7.2.war;     cp /tmp/solr-4.7.2/example/lib/ext/*.jar WEB-INF/lib",
            'cwd'     =>  '/usr/share/solr',
            'onlyif'  =>  'test ! -d /usr/share/solr/WEB-INF',
            'require' =>  'Exec[extract-solr]',
          )
        end
        it do
          is_expected.to contain_solr__core('default').with(
            'require'=>  'File[/usr/share/jetty/webapps/solr]',
          )
        end
      end
      context "when params are passed" do
        let(:params) do
          {
            :cores     => ['dev', 'prod'],
            :version   => '5.6.2',
            :mirror    => 'http://some-random-site.us',
            :dist_root => '/opt/tmpdata',
          } 
        end
        it do
          is_expected.to contain_file('/etc/default/jetty').with(
            'ensure'  =>    'file',
            'source'  =>    'puppet:///modules/solr/jetty-default',
            'require' =>    'Package[jetty]',
          )
        end
        it do
          is_expected.to contain_file('/usr/share/solr').with(
            'ensure'  =>  'directory',
            'owner'   =>  'jetty',
            'group'   =>  'jetty',
            'require' =>  'Package[jetty]',
          )
        end
        it do
          is_expected.to contain_file('/var/lib/solr').with(
            'ensure'  => 'directory',
            'owner'   => 'jetty',
            'group'   => 'jetty',
            'mode'    => '0700',
            'require' => 'Package[jetty]',
          )
        end
        it do
          is_expected.to contain_file('/usr/share/solr/solr.xml').with(
            'ensure'  => 'file',
            'owner'   => 'jetty',
            'group'   => 'jetty',
            'require' => 'File[/etc/default/jetty]',
          )
        end
        it do
          is_expected.to contain_file('/usr/share/solr/solr.xml')
          .with_content(/\/var\/lib\/solr\/prod/)
          .with_content(/\/var\/lib\/solr\/dev/)
        end
        it do
          is_expected.to contain_file('/usr/share/jetty/webapps/solr').with(
            'ensure'  => 'link',
            'target'  => '/usr/share/solr',
            'require' => 'File[/usr/share/solr/solr.xml]',
          )
        end
        it do
          is_expected.to contain_exec('solr-download').with(
            'command' =>  'wget http://some-random-site.us/5.6.2/solr-5.6.2.tgz',
            'cwd'     =>  '/opt/tmpdata',
            'creates' =>  '/opt/tmpdata/solr-5.6.2.tgz',
            'onlyif'  =>  'test ! -d /usr/share/solr/WEB-INF && test ! -f /opt/tmpdata/solr-5.6.2.tgz',
            'timeout' =>  0,
            'require' =>  'File[/usr/share/solr]'
          )
        end 
        it do
          is_expected.to contain_exec('extract-solr').with(
            'path'    =>  '["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin"]',
            'command' =>  'tar xvf solr-5.6.2.tgz',
            'cwd'     =>  '/opt/tmpdata',
            'onlyif'  =>  'test -f /opt/tmpdata/solr-5.6.2.tgz && test ! -d /opt/tmpdata/solr-5.6.2',
            'require' =>  'Exec[solr-download]',
          )
        end
        it do
          is_expected.to contain_exec('copy-solr').with(
            'path'    =>  '["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin"]',
            'command' =>  "jar xvf /opt/tmpdata/solr-5.6.2/dist/solr-5.6.2.war;     cp /opt/tmpdata/solr-5.6.2/example/lib/ext/*.jar WEB-INF/lib",
            'cwd'     =>  '/usr/share/solr',
            'onlyif'  =>  'test ! -d /usr/share/solr/WEB-INF',
            'require' =>  'Exec[extract-solr]',
          )
        end
        it do 
          is_expected.to contain_solr__core('dev').with(
            'require' =>  'File[/usr/share/jetty/webapps/solr]',
          )
        end 
        it do 
          is_expected.to contain_solr__core('prod').with(
            'require' =>  'File[/usr/share/jetty/webapps/solr]',
          )
        end
      end
    end
  end
end
