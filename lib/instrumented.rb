require 'singleton'
require_relative 'dropwizard'

class Instrumented < Dropwizard
  
  NAME_PREFIX = "responseCodes."
  OK = 200;
  CREATED = 201;
  NO_CONTENT = 204;
  RESET_CONTENT = 205;
  BAD_REQUEST = 400;
  NOT_FOUND = 404;
  SERVER_ERROR = 500;

  def initialize(metrics, name = 'dropwizard')
    super( metrics, name,
           { OK => NAME_PREFIX + "ok",
             CREATED => NAME_PREFIX + "created",
             NO_CONTENT => NAME_PREFIX + "noContent",
             RESET_CONTENT => NAME_PREFIX + "resetContent",
             BAD_REQUEST => NAME_PREFIX + "badRequest",
             NOT_FOUND => NAME_PREFIX + "notFound",
             SERVER_ERROR => NAME_PREFIX + "serverError" } )
  end
    
end

java_import java.util.concurrent.TimeUnit
java_import com.codahale.metrics.MetricFilter
java_import com.fasterxml.jackson.databind.ObjectMapper
java_import com.fasterxml.jackson.databind.ObjectWriter
java_import com.codahale.metrics.json.MetricsModule

module Rack
  module Dropwizard
    class Instrumented
      
      def initialize(app, instrumented)
        @app = app
        @dropwizard = instrumented
      end
      
      def call(env)
        @dropwizard.process( @app, env )
      end
      
    end
    
    class Metrics
      MAPPER = ObjectMapper.new
        .registerModule(MetricsModule.new(TimeUnit::SECONDS,
                                          TimeUnit::SECONDS,
                                          true,
                                          MetricFilter::ALL))

      def initialize(app, metrics)
        @app = app
        @metrics = metrics
      end
      
      def call(env)
        if env['PATH_INFO'] == '/metrics'
          [ 
           200, 
           {"Cache-Control" => "must-revalidate,no-cache,no-store"}, 
           [ metrics_json( env ) ]
          ]
        else
          @app.call( env )
        end
      end
       
      private

      def metrics_json( env )
        output = java.io.ByteArrayOutputStream.new
        writer( env ).writeValue(output, @metrics);
        output.to_s
      end

      def writer( env )
        prettyPrint = env[ 'QUERY_STRING' ] == 'pretty'
        if (prettyPrint)
          MAPPER.writerWithDefaultPrettyPrinter
        else
          MAPPER.writer
        end
      end
    end
  end
end

