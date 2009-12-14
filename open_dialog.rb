require 'gtk2'

class OpenDialog < Gtk::FileChooserDialog

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
