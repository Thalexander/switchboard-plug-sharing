/*
 * Copyright (c) 2016-2017 elementary LLC (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class Sharing.Widgets.BluetoothPage : Granite.SimpleSettingsPage {
    private GLib.Settings bluetooth_settings;
    private GLib.Settings sharing_settings;
    private Gtk.ComboBoxText accept_combo;
    private Gtk.Switch notify_switch;

    public BluetoothPage () {
        Object (
            activatable: true,
            description: _("While enabled, bluetooth devices can send files to Downloads."),
            icon_name: "preferences-bluetooth",
            title: _("Bluetooth")
        );
    }

    construct {
        var notify_label = new Gtk.Label (_("Notify about newly received files:"));
        notify_label.xalign = 1;

        notify_switch = new Gtk.Switch ();
        notify_switch.halign = Gtk.Align.START;

        var accept_label = new Gtk.Label (_("Accept files from bluetooth devices:"));
        accept_label.xalign = 1;

        accept_combo = new Gtk.ComboBoxText ();
        accept_combo.hexpand = true;
        accept_combo.append ("always", _("Always"));
        accept_combo.append ("bonded", _("When paired"));
        accept_combo.append ("ask", _("Ask me"));

        /*alert_view.title = _("Bluetooth Sharing Is Not Available");
        alert_view.description = _("The bluetooth device is either disconnected or disabled. Check bluetooth settings and try again.");
        alert_view.icon_name ="bluetooth-disabled-symbolic";*/

        content_area.attach (notify_label, 0, 0, 1, 1);
        content_area.attach (notify_switch, 1, 0, 1, 1);
        content_area.attach (accept_label, 0, 1, 1, 1);
        content_area.attach (accept_combo, 1, 1, 1, 1);

        var link_button = new Gtk.LinkButton.with_label ("settings://network/bluetooth", _("Bluetooth settings…"));
        action_area.add (link_button);

        bluetooth_settings = new GLib.Settings ("org.pantheon.desktop.wingpanel.indicators.bluetooth");
        sharing_settings = new GLib.Settings ("org.gnome.desktop.file-sharing");

        sharing_settings.bind ("bluetooth-obexpush-enabled", status_switch, "active", SettingsBindFlags.NO_SENSITIVITY);
        sharing_settings.bind ("bluetooth-accept-files", accept_combo, "active-id", SettingsBindFlags.DEFAULT);
        sharing_settings.bind ("bluetooth-notify", notify_switch, "active", SettingsBindFlags.DEFAULT);

        status_switch.notify ["active"].connect (() => {
            set_service_state ();
        });

        bluetooth_settings.changed ["bluetooth-enabled"].connect (() => {
            set_service_state ();
        });

        set_service_state ();
    }

    private void set_service_state () {
        if (bluetooth_settings.get_boolean ("bluetooth-enabled")) {
            status_switch.sensitive = true;
            if (sharing_settings.get_boolean ("bluetooth-obexpush-enabled")) {
                status_type = Granite.SettingsPage.StatusType.SUCCESS;
                status = Granite.SettingsPage.ENABLED;
            } else {
                status_type = Granite.SettingsPage.StatusType.OFFLINE;
                status = Granite.SettingsPage.DISABLED;
            }
        } else {
            status_switch.sensitive = false;
            status_type = Granite.SettingsPage.StatusType.ERROR;
            status = _("Not Available");
        }
    }
}
