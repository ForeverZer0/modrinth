
require_relative 'lib/modrinth'

def self.svg2img(svg, path, width = 24, height = 24, transparency = true)
  begin
    require 'rmagick'
    img, info = Magick::Image.from_blob(svg) do |info|
      info.format = 'SVG'
      info.background_color = 'transparent' if transparency
      info.size = "#{width}x#{height}"
    end
    !!img.write(path)
  rescue Gem::LoadError
    warn('SVG conversion requires the optional gem dependency "rmagick"')
    false
  end
end


project = Modrinth.project('sodium')
puts project.to_json(true)