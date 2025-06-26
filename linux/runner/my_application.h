#ifndef FLUTTER_MY_APPLICATION_H_
#define FLUTTER_MY_APPLICATION_H_

#include <gtk/gtk.h>
#include <flutter_linux/flutter_linux.h>
#include <string>

G_DECLARE_FINAL_TYPE(MyApplication, my_application, MY, APPLICATION,
                     GtkApplication)

/**
 * my_application_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #MyApplication.
 */
MyApplication* my_application_new();

bool get_bool_arg(FlValue *args, const gchar* key);
std::string get_string_arg(FlValue *args, const gchar* key);
int get_int_arg(FlValue *args, const gchar* key);
double get_double_arg(FlValue *args, const gchar* key);

// static void music_method_call_handler(FlMethodChannel *channel,
//     FlMethodCall *method_call,
//     gpointer user_data);

#endif  // FLUTTER_MY_APPLICATION_H_
