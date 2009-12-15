#!/usr/bin/env ruby
#
# This file is gererated by ruby-glade-create-template 1.1.4.
#
require 'libglade2'
require 'lib/trapezoidal_maps.rb'
require 'lib/bounding_box'
require 'lib/trapezoid'
require 'lib/xnode'
require 'lib/ynode'
require 'lib/trapezoid_node'
require 'lib/point'
require 'lib/segment'
require 'lib/drawer'
require 'lib/graph'
require 'lib/planning'
require 'lib/convex_hull'
require 'about'
require 'open_dialog'
require 'save_dialog'

PROG_NAME = "Robot Planning"

class RobotplanningGlade
  include GetText
  MAXX = 799
  MAXY = 438
  attr :glade
  
  # Creates tooltips.
  def create_tooltips
    @tooltip = Gtk::Tooltips.new
    @glade['toolbar_new'].set_tooltip(@tooltip, _('Novo'))
    @glade['toolbar_open'].set_tooltip(@tooltip, _('Abrir'))
    @glade['toolbar_save'].set_tooltip(@tooltip, _('Salvar'))
    @glade['toolbar_record_points'].set_tooltip(@tooltip, _('Adicionar Pontos'))
    @glade['toolbar_move'].set_tooltip(@tooltip, _('Mover Robô'))
  end
  
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    @drawer = Drawer.new(@glade['drawingarea'].window)
    @planning = Planning.new(@drawer, @glade['toolbar_generate_map'])
    @open_dialog = OpenDialog.new self.method(:open)
    @save_dialog = SaveDialog.new self.method(:save)
    @show_graph = true
    @show_trapezoids = true
    clean
    @glade['drawingarea'].signal_connect('expose_event')   { print }
    eventbox = @glade['eventbox']
    eventbox.events = Gdk::Event::BUTTON_PRESS_MASK
    eventbox.signal_connect('button_press_event') {|w, e| add_point(Point[e.x.to_i, e.y.to_i])}
    @glade['mainwindow'].signal_connect('destroy'){Gtk.main_quit}
    create_tooltips
    @glade['toolbar_save'].sensitive = false
  end
  
  def add_point(point)
    return if point.x < 1 || point.y < 1 || point.x > MAXX-1 || point.y > MAXY-1
    if @record_movement
      if @first_point
        @start = point
        @first_point = false
      else
        @finish = point
        @planning.locate(@start, @finish, @drawer)
        @glade['toolbar_move'].active = @record_movement = false
      end
    elsif @record_points
      @points << point
    end
  end
  
  def clean
    # rearranjar botões e booleans
    @first_point = true
    @record_points = false
    @glade['toolbar_record_points'].active = false
    @glade['toolbar_move'].active = false
    @record_movement = false
    @current_file = nil
    @segments = []
    @planning.clear
    @glade['mainwindow'].title = PROG_NAME
  end
  
  def open(filename)
    clean
    File.open(filename) do |f|
      while(line = f.gets)
        line.strip!
        if !line.start_with?('#')
          values = line.split.collect {|x| x.to_i}
          @segments << Segment[Point[values[0], values[1]], Point[values[2], values[3]]]
        end
      end
    end
    @current_file = filename
    @glade['mainwindow'].title = PROG_NAME + " - " + File.basename(filename)
    print
  end
  
  def save(filename)
    File.open(filename, 'w') do |f|
      @segments.each do |s|
        f.puts "#{s.start.x} #{s.start.y} #{s.finish.x} #{s.finish.y}"
      end
    end
    @current_file = filename
    @glade['mainwindow'].title = PROG_NAME + " - " + File.basename(filename)
  end
  
  def print
    @drawer.clear
    @planning.draw_ss if @show_trapezoids
    @planning.draw_graph if @show_graph
    @segments.each do |s|
      s.draw(@drawer)
    end
  end
    
  def on_menu_open_activate(widget)
    on_toolbar_open_clicked(widget)
  end

  def on_toolbar_open_clicked(widget)
    @open_dialog.show
  end

  def on_menu_save_activate(widget)
    on_toolbar_save_clicked(widget)
  end

  def on_toolbar_save_clicked(widget)
    if @current_file
      save(@current_file)
    else
      @save_dialog.show
    end
  end
  
  def on_menu_save_as_activate(widget)
    @save_dialog.show
  end

  def on_menu_close_activate(widget)
    puts "on_menu_close_activate() is not implemented yet."
  end
  
  def on_about_activate(widget)
    AboutDialog.new.show
  end
  
  def on_menu_new_activate(widget)
    on_toolbar_new_clicked(widget)
  end

  def on_toolbar_new_clicked(widget)
    clean
    print
  end
  
  #Funções de Entrada de Dados
  # Start reading points to move the robot
  def on_toolbar_move_toggled(widget)
    if @record_points
      @glade['toolbar_move'].active = false
    else 
      @record_movement = !@record_movement
      @first_point = true
    end
  end  
  
  #Start reading point to make the convex hull
  def on_toolbar_record_poits_toggled(widget)
    if @record_movement
      @glade['toolbar_record_points'].active = false    
    else      
      @record_points = !@record_points
      @points = [] if @record_points
      if !@record_points
        @planning.clear
        @segments += ConvexHull.generate(@points)
        print
      end
    end
  end
  
  #depends on the current active action
  def on_add_point_clicked(widget)
    add_point(Point[@glade['xvalue'].text.to_i, @glade['yvalue'].text.to_i])
  end
    
  def on_show_graph_activate(widget)
    @show_graph = !@show_graph
  end

  def on_show_trapezoids_activate(widget)
    @show_trapezoids = !@show_trapezoids
  end

  # Funções de Animação
  def on_speedscale_value_changed(widget)
    @planning.speed = glade['speedscale'].value
  end

  def on_toolbar_next_step_clicked(widget)
    puts "on_next_step_clicked() is not implemented yet."
  end

  def on_stepbystep_toggled(widget)
    @planning.change_step_by_step
  end

  def on_toolbar_generate_map_toggled(widget)
    @planning.start(@segments, MAXX, MAXY) if !@planning.playing
  end
  
  #Funções de menu
  def on_color_segments_activate(widget)
    puts "on_color_segments_activate() is not implemented yet."
  end
  
  def on_colors_graph_activate(widget)
    puts "on_colors_graph_activate() is not implemented yet."
  end

  def on_color_trapezoids_activate(widget)
    puts "on_color_trapezoids_activate() is not implemented yet."
  end
  
  def on_color_robot_activate(widget)
    puts "on_color_robot_activate() is not implemented yet."
  end

end

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = "robotplanning.glade"
  RobotplanningGlade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end