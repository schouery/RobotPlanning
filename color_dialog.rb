require 'gtk2'
class ColorDialog < Gtk::ColorSelectionDialog

  def initialize(&callback)
    super("Escolha a cor")
    ok_button.signal_connect('clicked') do
      callback.call(colorsel.current_color)
      hide
    end
    cancel_button.signal_connect('clicked') do
      hide
    end
  end
end
