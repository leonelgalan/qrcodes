require 'sinatra'

get '/' do
  'Visit /generate?url= to generate a QR Code for the specified URL'
end

get '/generate' do
  @qr_code_url = "https://chart.googleapis.com/chart?cht=qr&chs=300x300&chl=#{params[:url]}&chld=H|0"
  erb :generate
end