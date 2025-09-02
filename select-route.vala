// Компилируется с помощью:
// valac --pkg gtk+-3.0 tunnel-applet.vala

using Gtk;
using GLib;

// Функция для проверки существования маршрута
public bool route_exists() {
    int exit_status;
    try {
        Process.spawn_sync(null, new string[] {"sh", "-c", "ip r | grep -q 'default via 10.0.0.2'"}, null, SpawnFlags.SEARCH_PATH, null, null, null, out exit_status);
    } catch (SpawnError e) {
        // If the command fails to spawn, assume route doesn't exist for our purposes.
        return false;
    }
    return exit_status == 0;
}

public class Applet : Object {
    private StatusIcon status_icon;
    private Gtk.Menu menu;
    private Gtk.MenuItem start_item;
    private Gtk.MenuItem stop_item;

    public Applet() {
        // Создаём иконку в трее
        status_icon = new StatusIcon.from_icon_name("network-vpn-symbolic");
        status_icon.tooltip_text = "VPN Tunnel Control";


        // Создаём меню
        menu = new Gtk.Menu();

        // Пункт меню для включения туннеля
                start_item = new Gtk.MenuItem.with_label("Start Tunnel");
        start_item.activate.connect(() => {
            // Выполняем команду для добавления маршрута
            Process.spawn_command_line_async("sudo ip r a default via 10.0.0.2 metric 10");
        });
        menu.append(start_item);

        // Пункт меню для выключения туннеля
                stop_item = new Gtk.MenuItem.with_label("Stop Tunnel");
        stop_item.activate.connect(() => {
            // Выполняем команду для удаления маршрута
            Process.spawn_command_line_async("sudo ip r d default via 10.0.0.2");
        });
        menu.append(stop_item);

        
        menu.append(new Gtk.SeparatorMenuItem());

        // Пункт меню для выхода из приложения
                var quit_item = new Gtk.MenuItem.with_label("Quit");
        quit_item.activate.connect(() => {
            Gtk.main_quit();
        });
        menu.append(quit_item);

        menu.show_all();

        // Update status on right-click before showing menu
        status_icon.popup_menu.connect((button, time) => {
            update_status();
            menu.popup_at_pointer(null);
        });

        // Initial status check
        update_status();

        // Periodically update status
        GLib.Timeout.add_seconds(2, () => {
            update_status();
            return true; // Keep timer running
        });
    }

    private void update_status() {
        bool is_active = route_exists();
        GLib.debug("Updating status. Route exists: %s", is_active.to_string());

        if (is_active) {
            start_item.set_sensitive(false);
            stop_item.set_sensitive(true);
            status_icon.set_from_icon_name("network-vpn"); // Active icon
            status_icon.tooltip_text = "VPN Tunnel: Active";
        } else {
            start_item.set_sensitive(true);
            stop_item.set_sensitive(false);
            status_icon.set_from_icon_name("network-vpn-symbolic"); // Inactive icon
            status_icon.tooltip_text = "VPN Tunnel: Inactive";
        }
    }
}

public static int main(string[] args) {
    Gtk.init(ref args);
    new Applet();
    Gtk.main();
    return 0;
}