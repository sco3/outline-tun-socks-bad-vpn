// Компилируется с помощью:
// valac --pkg gtk+-3.0 --pkg appindicator3-0.1 select-route.vala

using Gtk;
using GLib;
using AppIndicator;

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
    private Indicator indicator;
    private Gtk.Menu menu;
    private Gtk.MenuItem start_item;
    private Gtk.MenuItem stop_item;

    public Applet() {
        indicator = new Indicator("vpn-tunnel-applet", "network-vpn-symbolic", AppIndicator.IndicatorCategory.APPLICATION_STATUS);
        indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE);

        menu = new Gtk.Menu();

        start_item = new Gtk.MenuItem.with_label("Start Tunnel");
        start_item.activate.connect(() => {
            try {
                Process.spawn_command_line_async("sudo ip r a default via 10.0.0.2 metric 10");
            } catch (SpawnError e) {
                warning("Error starting tunnel: %s", e.message);
            }
        });
        menu.append(start_item);

        stop_item = new Gtk.MenuItem.with_label("Stop Tunnel");
        stop_item.activate.connect(() => {
            try {
                Process.spawn_command_line_async("sudo ip r d default via 10.0.0.2");
            } catch (SpawnError e) {
                warning("Error stopping tunnel: %s", e.message);
            }
        });
        menu.append(stop_item);

        menu.append(new Gtk.SeparatorMenuItem());

        var quit_item = new Gtk.MenuItem.with_label("Quit");
        quit_item.activate.connect(() => {
            Gtk.main_quit();
        });
        menu.append(quit_item);

        menu.show_all();
        indicator.set_menu(menu);

        update_status();

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
            indicator.set_icon_full("network-vpn-symbolic", "VPN Tunnel: Active");
        } else {
            start_item.set_sensitive(true);
            stop_item.set_sensitive(false);
            indicator.set_icon_full("network-vpn-disabled-symbolic", "VPN Tunnel: Inactive");
        }
    }
}

public static int main(string[] args) {
    Gtk.init(ref args);
    new Applet();
    Gtk.main();
    return 0;
}
