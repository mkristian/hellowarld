require 'sinatra'
require 'json'
require 'ostruct'
require 'lib/instrumented'

data = OpenStruct.new
data.surname = 'meier'
data.firstname = 'christian'

configure do
  registry = Registry.new
  set :registry, registry

  # share the metrics
  use Rack::Dropwizard::Metrics, registry
  use Rack::Dropwizard::Health, registry

  # use on instrumented instance for all requests - must be thread-safe
  use Rack::Dropwizard::Instrumented, Instrumented.new( registry )

  registry.register_gauge('app.data_length' ) do
    data.surname.length + data.firstname.length
  end

  registry.register_health_check( 'app.health' ) do
    if data.surname.length + data.firstname.length < 4
      "stored names are too short"
    end
  end
end

histogram = settings.registry.histogram( 'app.name_length' )

get '/app' do
  p @person = data
  erb :person
end

get '/person' do
  p @person = data
  content_type 'application/json'
  { :surname =>  data.surname, :firstname => data.firstname }.to_json
end

patch '/person' do
  payload = JSON.parse request.body.read
  data.send :"#{payload.keys.first}=", payload.values.first
  histogram.update( data.surname.length + data.firstname.length )
  status 205
end
