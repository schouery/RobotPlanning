require 'gtk2'

# A open file dialog
class OpenDialog < Gtk::FileChooserDialog
  # Receives a callback that should be called when a file is chosen and ok is clicked
  def initialize(callback)
    super()
    @cancel = add_button(Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL)
    @cancel.signal_connect('clicked') { hide }
    @open = add_button(Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT)
    @open.signal_connect('clicked') do
      if self.filename && !File.directory?(self.filename)
        callback.call(self.filename)
        hide
      end
    end
  end

end
