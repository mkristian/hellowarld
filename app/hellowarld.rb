require 'sinatra'
require 'json'
require 'ostruct'

data = OpenStruct.new
data.surname = 'meier'
data.firstname = 'christian'

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
