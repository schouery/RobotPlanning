#include <gtk/gtk.h>


void
on_menu_new_activate                   (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_menu_open_activate                  (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_menu_save_activate                  (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_menu_save_as_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_menu_close_activate                 (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_show_trapezoids_activate            (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_show_graph_activate                 (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_colors_graph_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_color_trapezoids_activate           (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_color_segments_activate             (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_color_robot_activate                (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_sobre_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_toolbar_new_clicked                 (GtkToolButton   *toolbutton,
                                        gpointer         user_data);

void
on_toolbar_open_clicked                (GtkToolButton   *toolbutton,
                                        gpointer         user_data);

void
on_toolbar_save_clicked                (GtkToolButton   *toolbutton,
                                        gpointer         user_data);

void
on_toolbar_record_poits_toggled        (GtkToggleToolButton *toggletoolbutton,
                                        gpointer         user_data);

void
on_toolbar_move_clicked                (GtkToolButton   *toolbutton,
                                        gpointer         user_data);

gboolean
on_drawingarea_expose_event            (GtkWidget       *widget,
                                        GdkEventExpose  *event,
                                        gpointer         user_data);

gboolean
on_drawingarea_button_press_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_drawingarea_motion_notify_event     (GtkWidget       *widget,
                                        GdkEventMotion  *event,
                                        gpointer         user_data);

void
on_speedscale_value_changed            (GtkRange        *range,
                                        gpointer         user_data);

void
on_stepbystep_toggled                  (GtkToggleButton *togglebutton,
                                        gpointer         user_data);

void
on_add_point_clicked                   (GtkButton       *button,
                                        gpointer         user_data);

void
on_togglebutton1_toggled               (GtkToggleButton *togglebutton,
                                        gpointer         user_data);

void
on_next_step_clicked                   (GtkButton       *button,
                                        gpointer         user_data);
