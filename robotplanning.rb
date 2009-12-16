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
require 'color_dialog'

PROG_NAME = "Robot Planning"

class RobotplanningGlade
  include GetText
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
    @drawer = Drawer.new(@glade['drawingarea'].window, @glade['drawingarea'].style.black_gc)
    @planning = Planning.new(@drawer)
    @open_dialog = OpenDialog.new self.method(:open)
    @save_dialog = SaveDialog.new self.method(:save)
    
    @segment_color_dialog = ColorDialog.new do |color|
      @drawer.segments_color = color
    end
    
    @graph_color_dialog = ColorDialog.new do |color|
      @drawer.graph_color = color
    end

    @trapezoid_color_dialog = ColorDialog.new do |color|
      @drawer.trapezoid_base_color = color
    end

    @robot_color_dialog = ColorDialog.new do |color|
      @drawer.robot_base_color = color
    end
        
    clean
    connect_signals
    create_tooltips
    update_size
  end
  
  def connect_signals
    @glade['drawingarea'].signal_connect('expose_event')   { print }
    @glade['eventbox'].events = Gdk::Event::BUTTON_PRESS_MASK
    @glade['eventbox'].signal_connect('button_press_event') {|w, e| add_point(Point[e.x.to_i, e.y.to_i])}
    @glade['mainwindow'].signal_connect('destroy'){Gtk.main_quit}    
  end
  
  def update_size
    @max_x = @glade['drawingarea'].allocation.width - 1
    @max_y = @glade['drawingarea'].allocation.height - 1
    @glade['xvalue'].set_range(1,@max_x)
    @glade['yvalue'].set_range(1,@max_y)
  end
  
  def add_point(point)
    return if point.x < 1 || point.y < 1 || point.x > @max_x-1 || point.y > @max_y-1
    if @glade['toolbar_move'].active?
      if @first_point        
        @start = point
        @first_point = false
        @points = [@start]
        print
      else
        @finish = point
        @points = []
        move
      end
    elsif @glade['toolbar_record_points'].active?
      @points << point
      print
    end
  end
  
  def move
    @glade['toolbar_next_step'].sensitive = @planning.step_by_step
    @glade['add_point'].sensitive = false
    @locate_thread = @planning.locate(@start, @finish) {move_finished}
  end
  
  def move_finished
    @glade['toolbar_next_step'].sensitive = false
    @glade['toolbar_generate_map'].sensitive = true
    @glade['toolbar_record_points'].sensitive = true
    @locate_thread = nil
    @glade['toolbar_move'].active = false
  end
  
  def map_finished
    @glade['toolbar_next_step'].sensitive = false
    @glade['toolbar_move'].sensitive = true
    @glade['toolbar_record_points'].sensitive = true
    @glade['toolbar_generate_map'].active = false
    @map_thread = nil
  end
  
  def clean
    @first_point = true
    @locate_thread.kill if @locate_thread
    if @map_thread
        @glade['toolbar_generate_map'].active = false
        @map_thread.kill
    end
    @glade['toolbar_move'].sensitive = false
    @glade['toolbar_next_step'].sensitive = false
    @glade['add_point'].sensitive = true
    @glade['toolbar_record_points'].sensitive = true
    @glade['toolbar_record_points'].active = false if @glade['toolbar_record_points'].active?
    @glade['toolbar_move'].active = false if @glade['toolbar_move'].active?
    @current_file = nil
    @segments = []
    @points = []
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
    @planning.draw
    @segments.each do |s|
      s.draw(@drawer)
    end
    @points.each do |p|
      @drawer.draw_circle(p.x, p.y, 3)
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
    @glade['mainwindow'].destroy
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
  
  def on_toolbar_record_poits_toggled(widget)
    @glade['add_point'].sensitive = @glade['toolbar_record_points'].active?
    @glade['toolbar_generate_map'].sensitive = !@glade['toolbar_record_points'].active?
    @glade['toolbar_move'].sensitive = false if @glade['toolbar_record_points'].active?
    if !@glade['toolbar_record_points'].active?
      @planning.clear
      @segments += ConvexHull.generate(@points)
      @points = []
      print
    end
  end

  def on_toolbar_generate_map_toggled(widget)
    if !@glade['toolbar_generate_map'].active?
      @planning.stop = true if @map_thread
    else
      @glade['toolbar_next_step'].sensitive = false
      @glade['toolbar_move'].sensitive = false
      @glade['toolbar_record_points'].sensitive = false
      @glade['toolbar_next_step'].sensitive = @planning.step_by_step
      @map_thread = @planning.start(@segments, @max_x, @max_y) {map_finished}
    end
  end

  def on_toolbar_move_toggled(widget)
    if @glade['toolbar_move'].active?
      @glade['toolbar_generate_map'].sensitive = false
      @glade['toolbar_record_points'].sensitive = false
      @glade['add_point'].sensitive = true
      @first_point = true      
    else
      @planning.stop = true if @locate_thread
    end
  end  

  #depends on the current active action
  def on_add_point_clicked(widget)
    add_point(Point[@glade['xvalue'].text.to_i, @glade['yvalue'].text.to_i])
  end
    
  def on_show_graph_activate(widget)
    @planning.show_graph = widget.active?
    print
  end

  def on_show_trapezoids_activate(widget)
    @planning.show_trapezoids = widget.active?
    print
  end

  # Funções de Animação
  def on_speedscale_value_changed(widget)
    @planning.speed = glade['speedscale'].value
  end

  def on_toolbar_next_step_clicked(widget)
    puts "on_next_step_clicked() is not implemented yet."
  end

  def on_stepbystep_toggled(widget)
    @planning.step_by_step = widget.active?
    @glade['toolbar_next_step'].sensitive = false if !@planning.step_by_step
  end
  
  #Funções de menu
  def on_color_segments_activate(widget)
    @segment_color_dialog.show
  end
  
  def on_colors_graph_activate(widget)
    @graph_color_dialog.show
  end

  def on_color_trapezoids_activate(widget)
    @trapezoid_color_dialog.show
  end
  
  def on_color_robot_activate(widget)
    @robot_color_dialog.show
  end

end

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = "robotplanning.glade"
  RobotplanningGlade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end