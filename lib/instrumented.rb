require_relative 'metrics'

class AbstractIntrumented

  def initialize( registry, name, meter_names_by_status_code = {} )
    @meters_by_status_code = java.util.concurrent.ConcurrentHashMap.new
    meter_names_by_status_code.each do |k,v|
      @meters_by_status_code[ k ] = registry.register_meter( name, v )
    end
    @other = registry.register_meter( name, "other" )
    @active = registry.register_counter( name, "active_requests" )
    @timer = registry.register_timer( name, "requests" )
  end

  def process(app, env)
    @active.inc
    @context = @timer.time

    result = app.call(env)

  ensure
    @context.stop
    @active.dec
    mark_meter_for_status_code result[0]
  end

  def mark_meter_for_status_code( status )
    metric = @meters_by_status_code[ status ] || @other
    metric.mark
  end
end

class Instrumented < AbstractIntrumented
  
  NAME_PREFIX = "responseCodes."
  OK = 200;
  CREATED = 201;
  NO_CONTENT = 204;
  RESET_CONTENT = 205;
  BAD_REQUEST = 400;
  NOT_FOUND = 404;
  SERVER_ERROR = 500;

  def initialize( registry, name = 'dropwizard')
    super( registry, name,
           { OK => NAME_PREFIX + "ok",
             CREATED => NAME_PREFIX + "created",
             NO_CONTENT => NAME_PREFIX + "noContent",
             RESET_CONTENT => NAME_PREFIX + "resetContent",
             BAD_REQUEST => NAME_PREFIX + "badRequest",
             NOT_FOUND => NAME_PREFIX + "notFound",
             SERVER_ERROR => NAME_PREFIX + "serverError" } )
  end
    
end

module Rack
  module Dropwizard
    class Instrumented
      
      def initialize(app, instrumented)
        @app = app
        @instrumented = instrumented
      end
      
      def call(env)
        @instrumented.process( @app, env )
      end
      
    end
  end
end

