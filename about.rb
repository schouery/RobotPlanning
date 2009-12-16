require 'gtk2'

# A about dialog
class AboutDialog < Gtk::AboutDialog

  def initialize
    super()
    signal_connect('response') do |w, resp_id|
      w.destroy
    end    
    set_program_name 'Robot Planning'
    set_version '1.0'
    set_website 'http://mafagrafos.com'
    set_website_label 'Mafagrafos.com'
    set_logo Gdk::Pixbuf.new('r2d2.png', 86, 80)
    set_modal true
    set_authors ["Rafael Crivellari Saliba Schouery"]
  end

end
