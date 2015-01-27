begin
  # do not require jbundler if we have the java classes already
  java_import com.codahale.metrics.MetricRegistry
rescue
  require 'jbundler'
  retry
end

java_import com.codahale.metrics.MetricFilter
java_import com.codahale.metrics.json.MetricsModule
java_import com.codahale.metrics.json.HealthCheckModule

java_import com.fasterxml.jackson.databind.ObjectMapper

java_import java.util.concurrent.TimeUnit

class Registry

  class Gauge
    include com.codahale.metrics.Gauge
    
    def initialize( data )
      @data = data
    end
    
    def value
      @data.call
    end
  end

  class HealthCheck < com.codahale.metrics.health.HealthCheck
   
    def initialize( data )
      super()
      @data = data
    end
    
    def check
      if result = @data.call
        com.codahale.metrics.health.HealthCheck::Result.unhealthy( result )
      else
        com.codahale.metrics.health.HealthCheck::Result.healthy
      end
    end
  end
    
  attr_reader :metrics, :health

  def initialize
    @metrics = MetricRegistry.new
    @health = com.codahale.metrics.health.HealthCheckRegistry.new
  end

  def register_gauge( *name, &block )
    @metrics.register( name.join( '.'), Gauge.new( block ) )
  end

  def register_health_check( *name, &block )
    @health.register( name.join( '.'), HealthCheck.new( block ) )
  end

  def register_meter( *name )
    @metrics.meter( name.join( "." ) )
  end

  def register_counter( *name )
    @metrics.counter( name.join( "." ) )
  end

  def register_timer( *name )
    @metrics.timer( name.join( "." ) )
  end

  def histogram( *name )
    @metrics.histogram( name.join( '.' ) )
  end
end

class JsonWriter

  def initialize( flavour )
    @mapper = ObjectMapper.new.registerModule( flavour )
  end

  def data
    raise 'need implementation'
  end

  def to_json( pretty = false )
    # TODO make this stream
    output = java.io.ByteArrayOutputStream.new
    writer( pretty ).writeValue(output, data);
    output.to_s
  end
  
  private
  
  def writer( pretty )
    if pretty
      @mapper.writerWithDefaultPrettyPrinter
    else
      @mapper.writer
    end
  end
end

class RegistryWriter < JsonWriter

  def initialize( registry )
    super( # make the mapper configurable
           MetricsModule.new(TimeUnit::SECONDS,
                             TimeUnit::SECONDS,
                             true,
                             MetricFilter::ALL) )
    @metrics = registry.metrics
  end

  def data
    @metrics.metrics
  end
end

class HealthWriter < JsonWriter

  def initialize( registry )
    super( HealthCheckModule.new )
    @health = registry.health
  end

  def data
    # TODO run optional in parallel
    @health.runHealthChecks
  end

  def healthy?
    @health.healthy?
  end
end

module Rack
  module Dropwizard

    class Metrics

      def initialize(app, registry)
        @app = app
        @metrics = registry.is_a?( RegistryWriter ) ? registry : RegistryWriter.new( registry )
      end
      
      def call(env)
        if env['PATH_INFO'] == '/metrics'
          [ 
           200, 
           {"Cache-Control" => "must-revalidate,no-cache,no-store"}, 
           [ @metrics.to_json( env[ 'QUERY_STRING' ] == 'pretty' ) ]
          ]
        else
          @app.call( env )
        end
      end
    end
    class Health

      def initialize(app, registry)
        @app = app
        @health = registry.is_a?( HealthWriter ) ? registry : HealthWriter.new( registry )
      end
      
      def call(env)
        if env['PATH_INFO'] == '/health'
          [ 
           @health.healthy? ? 200 : 500, 
           {"Cache-Control" => "must-revalidate,no-cache,no-store"}, 
           [ @health.to_json( env[ 'QUERY_STRING' ] == 'pretty' ) ]
          ]
        else
          @app.call( env )
        end
      end
    end
  end
end
