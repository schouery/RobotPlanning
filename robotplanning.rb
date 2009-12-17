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
    @glade['toolbar_generate_map'].set_tooltip(@tooltip, _('Gerar Trapezoides'))
    @glade['toolbar_next_step'].set_tooltip(@tooltip, _('Próximo Passo'))
    @glade['add_point'].set_tooltip(@tooltip, _('Adicionar ponto'))
  end
  
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    # Glade start
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    # Glade finish
    @drawer = Drawer.new(@glade['drawingarea'].window, @glade['drawingarea'].style.black_gc)
    @planning = Planning.new(@drawer, @glade['statusbar'])
    @context = @glade['statusbar'].get_context_id("robotplanning")
    @glade['toolbar_next_step'].sensitive = false
    create_dialogs
    clean
    connect_signals
    create_tooltips
    update_size
  end
  
  # Creates all the dialogs of the project
  def create_dialogs
    @open_dialog = OpenDialog.new self.method(:open)
    @save_dialog = SaveDialog.new self.method(:save)
  
    @segment_color_dialog = ColorDialog.new do |c| 
      @drawer.segments_color = c
      print
    end
    
    @graph_color_dialog = ColorDialog.new  do |c| 
      @drawer.graph_color = c
      print
    end

    @trapezoid_color_dialog = ColorDialog.new do |c| 
      @drawer.trapezoid_base_fill_color = c
      print
    end
    
    @robot_color_dialog = ColorDialog.new do |c| 
      @drawer.robot_color = c
      print
    end
    
    @robot_line_color = ColorDialog.new do |c| 
      @drawer.robot_line_color = c
      print
    end
    
    @trapezoids_segment_color = ColorDialog.new do |c| 
      @drawer.trapezoid_segment_color = c
      print
    end
    
    @new_trapezoides = ColorDialog.new do |c| 
      @drawer.new_trapezoid_color = c
    end
      
    @destroied_trapezoids = ColorDialog.new do |c| 
      @drawer.old_trapezoid_color = c
    end
    
  end
  
  # Create some events that couldn't be created using ruby-glade
  def connect_signals
    @glade['drawingarea'].signal_connect('expose_event')   { print }
    @glade['eventbox'].events = Gdk::Event::BUTTON_PRESS_MASK
    @glade['eventbox'].signal_connect('button_press_event') {|w, e| add_point(Point[e.x.to_i, e.y.to_i])}
    @glade['mainwindow'].signal_connect('destroy'){Gtk.main_quit}    
  end
  
  # Update the size according to the drawing area size
  def update_size
    @max_x = @glade['drawingarea'].allocation.width - 1
    @max_y = @glade['drawingarea'].allocation.height - 1
    @glade['xvalue'].set_range(1,@max_x)
    @glade['yvalue'].set_range(1,@max_y)
  end
  
  # Adds a point, testing if we are searching or create polygons
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
      if @x_coords[point.x]
        @glade['statusbar'].push(@context, "Este programa não suporta 2 ou mais pontos com mesma X-coordenada!")
      else
        @points << point
        @x_coords[point.x] = point
      end
      print
    end
  end
  
  # Make a search and move the robot
  def move
    @glade['add_point'].sensitive = false
    @locate_thread = @planning.locate(@start, @finish) {move_finished}
  end
  
  # Called once the movement of the robot is finished
  def move_finished
    @glade['toolbar_generate_map'].sensitive = true
    @glade['toolbar_record_points'].sensitive = true
    @locate_thread = nil
    @glade['toolbar_move'].active = false
  end
  
  # Called once the generation of the map is finished
  def map_finished
    @glade['toolbar_move'].sensitive = true
    @glade['toolbar_record_points'].sensitive = true
    @glade['toolbar_generate_map'].active = false
  end
  
  # Cleanup for new or open files
  def clean
    @first_point = true
    @locate_thread.kill if @locate_thread
    if @map_thread
        @glade['toolbar_generate_map'].active = false
        @map_thread.kill
    end
    @glade['add_point'].sensitive = false
    @glade['toolbar_move'].sensitive = false
    @glade['toolbar_record_points'].sensitive = true
    @glade['toolbar_record_points'].active = false if @glade['toolbar_record_points'].active?
    @glade['toolbar_move'].active = false if @glade['toolbar_move'].active?
    @current_file = nil
    @segments = []
    @points = []
    @x_coords = Hash.new
    @planning.clear
    @glade['mainwindow'].title = PROG_NAME
  end
  
  # Opens a file
  def open(filename)
    clean
    File.open(filename) do |f|
      while(line = f.gets)
        line.strip!
        if !line.start_with?('#')
          values = line.split.collect {|x| x.to_i}
          p = Point[values[0], values[1]]
          q = Point[values[2], values[3]]
          if (!@x_coords[values[0]].nil? && @x_coords[values[0]] != p) ||
             (!@x_coords[values[2]].nil? && @x_coords[values[2]] != q)
            clean
            @glade['statusbar'].push(@context, "Arquivo inválido: 2 pontos com mesma X-coordenada. Arquivo ignorado.")
            return
          else
            @x_coords[values[0]] = p
            @x_coords[values[2]] = q
          end
          @segments << Segment[p,q]
        end
      end
    end
    @current_file = filename
    @glade['mainwindow'].title = PROG_NAME + " - " + File.basename(filename)
    print
  end
  
  # Save the current file
  def save(filename)
    File.open(filename, 'w') do |f|
      @segments.each do |s|
        f.puts "#{s.start.x} #{s.start.y} #{s.finish.x} #{s.finish.y}"
      end
    end
    @current_file = filename
    @glade['mainwindow'].title = PROG_NAME + " - " + File.basename(filename)
  end
  
  # Draw items on the screen
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
      @glade['toolbar_move'].sensitive = false
      @glade['toolbar_record_points'].sensitive = false
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

  def on_speedscale_value_changed(widget)
    @planning.speed = glade['speedscale'].value
  end

  def on_toolbar_next_step_clicked(widget)
    @planning.next_step
  end

  def on_stepbystep_toggled(widget)
    @planning.step_by_step = widget.active?
    @planning.step_by_step
    @glade['toolbar_next_step'].sensitive = @planning.step_by_step
  end
  
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

  def on_robot_line_activate(widget)
    @planning.show_line = widget.active?
  end
  
  def on_robot_line_color_activate(widget)
    @robot_line_color.show  
  end
  
  def on_trapezoids_segments_activate(widget)
    @trapezoids_segment_color.show
  end
  
  def on_new_trapezoides_activate(widget)
    @new_trapezoides.show
  end
  
  def on_destroied_trapezoids_activate(widget)
    @destroied_trapezoids.show
  end
end

# Main program
if __FILE__ == $0
  PROG_PATH = "robotplanning.glade"
  RobotplanningGlade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end