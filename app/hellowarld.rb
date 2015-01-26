require 'sinatra'
require 'json'
require 'ostruct'
require 'lib/instrumented'

configure do
  registry = Registry.new
  set :metrics, registry

  # share the metrics
  use Rack::Dropwizard::Metrics, registry.metrics

  # use on instrumented instance for all requests - must be thread-safe
  use Rack::Dropwizard::Instrumented, Instrumented.new( registry.metrics )
end

data = OpenStruct.new
data.surname = 'meier'
data.firstname = 'christian'

settings.metrics.register_gauge('app.data_length' ) do
  data.surname.length + data.firstname.length
end

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
  status 205
end
