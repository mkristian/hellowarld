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
end

patch '/surname' do
  payload = JSON.parse request.body.read
  data['surname'] = payload['surname']
  status 205
end

patch '/firstname' do
  payload = JSON.parse request.body.read
  data['firstname'] = payload['firstname']
  status 205
end
