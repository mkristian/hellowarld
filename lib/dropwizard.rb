require_relative 'metrics'

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

  attr_reader :metrics

  def initialize
    @metrics = MetricRegistry.new
  end

  def register_gauge( name, obj = nil, &block )
    @metrics.register( name, obj || Guage.new( block ) )
  end

end

class Dropwizard

  def initialize( metrics, name, meter_names_by_status_code = {} )
    @meters_by_status_code = java.util.concurrent.ConcurrentHashMap.new
    meter_names_by_status_code.each do |k,v|
      @meters_by_status_code[ k ] = metrics.meter(MetricRegistry.name(name, v))
    end
    @other = metrics.meter(MetricRegistry.name(name, "other"))
    @active = metrics.counter(MetricRegistry.name(name, "active_requests"))
    @timer = metrics.timer(MetricRegistry.name(name, "requests"))
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
