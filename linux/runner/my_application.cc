#include "my_application.h"
#include <flutter_linux/flutter_linux.h>
#include <flutter_linux/fl_value.h>
#include "metadata_retriever.h"
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#include <iostream>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication
{
  GtkApplication parent_instance;
  char **dart_entrypoint_arguments;
  FlMethodChannel *method_channel;
};

static void music_method_call_handler(FlMethodChannel *channel,
                                      FlMethodCall *method_call,
                                      gpointer user_data)
{
  g_autoptr(FlMethodResponse) response = nullptr;
  const gchar *method_name = fl_method_call_get_name(method_call);
  if (strcmp(method_name, "get_music_metadata") == 0)
  {
    FlValue *args = fl_method_call_get_args(method_call);

    FlValue *pathValue = fl_value_lookup_string(args, "path");

    const gchar *path = fl_value_get_string(pathValue);
    std::string str(path);

    std::map<std::string, std::string> data = MusicMetadata(str);

    g_autoptr(FlValue) result = fl_value_new_map();

    for (const auto &pair : data)
{
    std::cout << "key: " << pair.first << ", value: " << pair.second << std::endl;
}
    for (const auto &pair : data)
    {
      fl_value_set_string_take(result, pair.first.c_str(), fl_value_new_string(pair.second.c_str()));
    }
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  else if (strcmp(method_name, "get_album_cover") == 0)
  {
    FlValue *args = fl_method_call_get_args(method_call);

    FlValue *pathValue = fl_value_lookup_string(args, "path");

    const gchar *path = fl_value_get_string(pathValue);
    std::string str(path);

    std::vector<int> data = AlbumCover(str);

    g_autoptr(FlValue) result = fl_value_new_list();
    // for(const auto &child : data) {
    //   fl_value_append(&result, fl_value_new_int(child));
    // }

    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  else
  {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  g_autoptr(GError) error = nullptr;
  if (!fl_method_call_respond(method_call, response, &error))
  {
    g_warning("Failed to send response: %s", error->message);
  }
}

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Implements GApplication::activate.
static void my_application_activate(GApplication *application)
{
  MyApplication *self = MY_APPLICATION(application);
  GtkWindow *window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen *screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen))
  {
    const gchar *wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0)
    {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar)
  {
    GtkHeaderBar *header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "music");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  }
  else
  {
    gtk_window_set_title(window, "music");
  }

  //auto bdw = bitsdojo_window_from(window); // <--- add this line
  //bdw->setCustomFrame(true);               // <-- add this line
  //gtk_window_set_default_size(window, 1280, 720);   // <-- comment this line
  //gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView *view = fl_view_new(project);
  //gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->method_channel = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)),
      "music_method_channel", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      self->method_channel, music_method_call_handler, self, nullptr);

  gtk_widget_show(GTK_WIDGET(window));
  gtk_widget_show(GTK_WIDGET(view));
  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication *application, gchar ***arguments, int *exit_status)
{
  MyApplication *self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error))
  {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication *application)
{
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication *application)
{
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject *object)
{
  MyApplication *self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  g_clear_object(&self->method_channel);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass *klass)
{
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication *self) {}

MyApplication *my_application_new()
{
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}

bool get_bool_arg(FlValue *args, const gchar* key) 
{
  FlValue *value = fl_value_lookup_string(args, key);

  return fl_value_get_bool(value);
}

std::string get_string_arg(FlValue *args, const gchar* key) 
{
  FlValue *value = fl_value_lookup_string(args, key);

  const gchar *value_as_char = fl_value_get_string(value);
  std::string str(value_as_char);
  return str;
}

int get_int_arg(FlValue *args, const gchar* key)
{
  FlValue *value = fl_value_lookup_string(args, key);

  return static_cast<int>(fl_value_get_int(value));
}

double get_double_arg(FlValue *args, const gchar* key)
{
  FlValue *value = fl_value_lookup_string(args, key);
  return fl_value_get_float(value);
}