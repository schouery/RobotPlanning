#!/usr/bin/env ruby
#
# This file is gererated by ruby-glade-create-template 1.1.4.
#
require 'libglade2'

class RobotplanningGlade
  include GetText

  attr :glade
  
  # Creates tooltips.
  def create_tooltips
    @tooltip = Gtk::Tooltips.new
    @glade['toolbar_new'].set_tooltip(@tooltip, _('Novo'))
    @glade['toolbar_open'].set_tooltip(@tooltip, _('Abrir'))
    @glade['toolbar_save'].set_tooltip(@tooltip, _('Salvar'))
    @glade['toolbar_record_poits'].set_tooltip(@tooltip, _('Adicionar Pontos'))
    @glade['toolbar_move'].set_tooltip(@tooltip, _('Mover Robô'))
  end
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    
    create_tooltips
  end
  
  def on_color_segments_activate(widget)
    puts "on_color_segments_activate() is not implemented yet."
  end
  def on_colors_graph_activate(widget)
    puts "on_colors_graph_activate() is not implemented yet."
  end
  def on_menu_open_activate(widget)
    puts "on_menu_open_activate() is not implemented yet."
  end
  def on_next_step_clicked(widget)
    puts "on_next_step_clicked() is not implemented yet."
  end
  def on_stepbystep_toggled(widget)
    puts "on_stepbystep_toggled() is not implemented yet."
  end
  def on_toolbar_open_clicked(widget)
    puts "on_toolbar_open_clicked() is not implemented yet."
  end
  def on_toolbar_move_clicked(widget)
    puts "on_toolbar_move_clicked() is not implemented yet."
  end
  def on_color_trapezoids_activate(widget)
    puts "on_color_trapezoids_activate() is not implemented yet."
  end
  def on_menu_save_activate(widget)
    puts "on_menu_save_activate() is not implemented yet."
  end
  def on_sobre_activate(widget)
    puts "on_sobre_activate() is not implemented yet."
  end
  def on_toolbar_record_poits_toggled(widget)
    puts "on_toolbar_record_poits_toggled() is not implemented yet."
  end
  def on_add_point_clicked(widget)
    puts "on_add_point_clicked() is not implemented yet."
  end
  def on_toolbar_new_clicked(widget)
    puts "on_toolbar_new_clicked() is not implemented yet."
  end
  def on_menu_close_activate(widget)
    puts "on_menu_close_activate() is not implemented yet."
  end
  def on_color_robot_activate(widget)
    puts "on_color_robot_activate() is not implemented yet."
  end
  def on_menu_new_activate(widget)
    puts "on_menu_new_activate() is not implemented yet."
  end
  def on_show_trapezoids_activate(widget)
    puts "on_show_trapezoids_activate() is not implemented yet."
  end
  def on_togglebutton1_toggled(widget)
    puts "on_togglebutton1_toggled() is not implemented yet."
  end
  def on_toolbar_save_clicked(widget)
    puts "on_toolbar_save_clicked() is not implemented yet."
  end
  def on_show_graph_activate(widget)
    puts "on_show_graph_activate() is not implemented yet."
  end
  def on_speedscale_value_changed(widget)
    puts "on_speedscale_value_changed() is not implemented yet."
  end
  def on_menu_save_as_activate(widget)
    puts "on_menu_save_as_activate() is not implemented yet."
  end
end

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = "robotplanning.glade"
  PROG_NAME = "YOUR_APPLICATION_NAME"
  RobotplanningGlade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end
