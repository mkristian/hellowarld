require_relative 'metrics'

class Dropwizard

  def initialize( name, meter_names_by_status_code = {} )
    metrics = Metrics.instance
    @meters_by_status_code = {}
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
