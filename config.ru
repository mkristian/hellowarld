#\ -s webrick

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift($servlet_context.getRealPath("/WEB-INF")) if defined?($servlet_context)

require 'rubygems'
require 'lib/instrumented'
require 'app/hellowarld'

use Rack::Dropwizard::Metrics
use Rack::Dropwizard::Instrumented

map '/' do
  run Sinatra::Application
end
