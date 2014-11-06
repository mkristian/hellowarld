#-*- mode: ruby -*-

gemfile

packaging :war

jar( 'org.jruby.rack:jruby-rack', '1.2.0-SNAPSHOT', 
     :exclusions => [ 'org.jruby:jruby-complete' ] )

pom 'org.jruby:jruby', '1.7.12'

properties( 'project.build.sourceEncoding' => 'utf-8'  )

resource do
  directory '${basedir}'
  includes [ 'app/**', 'config.ru' ]
end

resource do
  directory '${basedir}'
  includes [ 'config.ru' ]
  target_path 'WEB-INF'
end

build do
  final_name File.basename( File.expand_path( '.' ) )
  directory 'pkg'
end

jruby_plugin!( :gem,
               :includeRubygemsInResources => true )

plugin( :war, '2.2',
        :webAppSourceDirectory => "${basedir}",
        :webResources => [ { :directory => '${basedir}',
                             :targetPath => 'WEB-INF',
                             :includes => [ 'config.ru' ] } ] )

#plugin( 'org.mortbay.jetty:jetty-maven-plugin', '8.1.14.v20131031',
#        :webAppSourceDirectory => "${basedir}" )
plugin( 'org.eclipse.jetty:jetty-maven-plugin', '9.3.0.M1',
        :webAppSourceDirectory => "${basedir}" )
