require 'dragonfly'

app = Dragonfly[:images]
app.configure_with(:imagemagick)
app.configure_with(:rails)

app.define_macro(ActiveRecord::Base, :image_accessor)

Dragonfly[:images].configure do |c|
  c.allow_fetch_file = true
  c.protect_from_dos_attacks = true
end