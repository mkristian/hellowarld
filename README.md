# show case to use PATCH verb with jruby-rack #

get all the gems in place

    bundle install

## with ruby-maven ##

needs 'org.jruby.rack:jruby-rack:1.2.0-SNAPSHOT' on maven repository (or just build the snapshot yourself).

run the application in a webserver, choose one:

	rmvn tomcat:run
	rmvn wildfly:run

they are all configured to be accessible with:

    http://localhost:8080/hellowarld

or

    rmvn jetty:run

via

    http://localhost:8080/

the config for all this is

* Mavenfile
* WEB-INF/web,xml

## with warbler ##

if there have jruby-rack-1.2.0.gem installed then you can create executable war with:

    warble executable

and run the war with

    jruby -jar hellowarld.war

with the config in

* config/warbler.xml
