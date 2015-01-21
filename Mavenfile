#-*- mode: ruby -*-

gemfile

packaging :war

jar( 'org.jruby.rack:jruby-rack', '1.1.14', 
     :exclusions => [ 'org.jruby:jruby-complete' ] )

pom 'org.jruby:jruby', '${jruby.version}'

properties( 'project.build.sourceEncoding' => 'utf-8',
            'jruby.version' => '1.7.16'  )

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

# jetty runner 
##############

#plugin( 'org.mortbay.jetty:jetty-maven-plugin', '8.1.14.v20131031',
#        :webAppSourceDirectory => "${basedir}" )
plugin( 'org.eclipse.jetty:jetty-maven-plugin', '9.3.0.M1',
        :webAppSourceDirectory => "${basedir}" )


# tomcat runner
###############
plugin( 'org.codehaus.mojo:tomcat-maven-plugin', '1.1',
        :warSourceDirectory => '${basedir}' )

# wildfly runner
################
plugin( :war, '2.2',
        :webAppSourceDirectory => "${basedir}",
        :webXml => 'WEB-INF/web.xml',
        :webResources => [ { :directory => '${basedir}',
                             :targetPath => 'WEB-INF',
                             :includes => [ 'config.ru' ] },
                           { :directory => '${basedir}/WEB-INF',
                             :targetPath => 'WEB-INF',
                             :includes => [ 'init.rb' ] } ] )

plugin( 'org.wildfly.plugins:wildfly-maven-plugin:1.0.2.Final' )
