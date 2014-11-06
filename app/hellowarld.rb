require 'sinatra'
require 'json'
require 'ostruct'

data = OpenStruct.new
data.surname = 'meier'
data.firstname = 'christian'

get '/' do
  @person = data
  erb :person
end

get '/person' do
  @person = data
  data.to_h.to_json
  content_type 'application/json'
end

patch '/person' do
  payload = JSON.parse request.body.read
  data[payload.keys.first] = payload.values.first
  status 205
end
