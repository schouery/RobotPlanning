require 'gtk2'
# A color choose dialog
class ColorDialog < Gtk::ColorSelectionDialog

  # Receives a callback that should be called when the color is chosen
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
