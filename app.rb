require 'sinatra'
require 'barby'
require 'barby/barcode/qr_code'
require 'barby/outputter/png_outputter'

get '/' do
  erb :index
end

get '/generate' do
  @qr_code_url = "/qr?url=#{params[:url]}&color=#{params[:color]}"
  erb :generate
end

get '/qr' do
  color = case params[:color]
  when 'red'
    '#FF0000'
  when 'green'
    '#00FF00'
  when 'blue'
    '#0000FF'
  else
    '#000000'
  end

  headers 'Content-Type' => 'img/png'
  Barby::QrCode.new(params[:url], level: :h).to_png(:margin => 0, :height => 300, :width => 300, xdim: 10, :color => ChunkyPNG::Color.from_hex(color), :bgcolor => ChunkyPNG::Color::TRANSPARENT)
end