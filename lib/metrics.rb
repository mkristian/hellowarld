begin
  # do not require jbundler if we have the java classes already
  java_import com.codahale.metrics.MetricRegistry
rescue
  require 'jbundler'
  retry
end

class Metrics

  def self.instance
    @instance ||= MetricRegistry.new
  end
end
