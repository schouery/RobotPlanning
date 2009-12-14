require 'gtk2'

class SaveDialog < Gtk::FileChooserDialog

  def initialize(callback)
    super()
    set_action Gtk::FileChooser::ACTION_SAVE
    @cancel = add_button(Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL)
    @cancel.signal_connect('clicked') { hide }
    @save = add_button(Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_ACCEPT)
    @save.signal_connect('clicked') do
      if self.filename && !File.directory?(self.filename)
        callback.call(self.filename)
        hide
      end
    end
  end

end
