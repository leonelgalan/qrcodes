require 'sinatra'
require 'barby'
require 'barby/barcode/qr_code'
require 'barby/outputter/png_outputter'
require 'data_mapper'
require 'RMagick'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/development.db")

class Link
  include DataMapper::Resource
  property :short_url, String, key: true
  property :url, String, length: 256
  property :title, String
end

DataMapper.finalize
DataMapper.auto_upgrade!

class String
  def titleize
    split(/(\W)/).map(&:capitalize).join
  end
end

helpers do
  def checkbox(name, value, label=value.titleize)
    "<input type=\"radio\" name=\"#{name}\" id=\"#{name}_#{value}\" value=\"#{value}\" /> <label for=\"#{name}_#{value}\">#{label}</label><br />"
  end
  
  def random_string
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    chars.sample + chars.sample + chars.sample
  end

  def gen_short_url
    tmp = random_string
    until Link.get(tmp).nil?
      tmp = random_string
    end

    tmp
  end
end

get '/' do
  erb :index
end

get '/generate' do
  @link = Link.new short_url: gen_short_url, url: params[:url], title: params[:title]

  if @link.save
    @qr_code_url = "/qr?url=http://acornco.de/#{@link.short_url}&color=#{params[:color]}&title=#{params[:title]}"
    erb :generate
  else
    status 400
    erb :index
  end
end

get '/qr' do
  color = case params[:color]
  when 'red'
    '#BD0A0A'
  when 'green'
    '#267519'
  when 'blue'
    '#134EAF'
  when 'brown'
    '#4B2E05'
  when 'purple'
    '#340645'
  else
    '#000000'
  end

  qr_code = Barby::QrCode.new(params[:url], level: :h)
  File.open("tmp.png", 'w'){|f|
    f.write qr_code.to_png(:margin => 0, :height => 300, :width => 300, xdim: 10, :color => ChunkyPNG::Color.from_hex(color), :bgcolor => ChunkyPNG::Color::WHITE)
  }
  
  src = Magick::Image.read("tmp.png").first
  dst = Magick::Image.read("images/#{params[:color]}.png").first
  result = dst.composite(src, Magick::CenterGravity, Magick::OverCompositeOp)
  
  gc = Magick::Draw.new
  gc.fill = 'white'
  gc.stroke = 'none'
  gc.pointsize = 42

  text = Magick::Draw.new
  text.font = 'DINPro-Medium.otf'
  text.pointsize = 52
  text.gravity = Magick::CenterGravity
  
  text.annotate(result, 0,0,0,300, params[:title]){
    self.fill = 'white'
  }
  
  headers 'Content-Type' => 'img/png'
  result.to_blob { self.format = "PNG" }
  #result.write('composite1.gif')
end

get '/:key' do
  @link = Link.get(params[:key])
  redirect @link.url
end