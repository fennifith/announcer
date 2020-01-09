import std.stdio: writeln;
import std.getopt;
import std.algorithm.comparison : min, max;
import std.math : log;
import std.conv: to;
import gio.Application : GioApplication = Application;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Widget;
import gtk.Entry;
import gtk.EditableIF;
import gtk.c.types : GtkStateFlags, GtkWindowPosition;
import gdk.RGBA;
import gdk.c.types : GdkRectangle, GdkEventKey;

struct Config {
	string text;
	int minWidth = -1;
	string font = "default";
	int fontSize = 72;
}

class Announcer : ApplicationWindow {

	private Config config;
	private GdkRectangle workarea;

	this(Application application, Config config) {
		super(application);
		this.config = config;

		setTitle("Announce");
		setKeepAbove(true);
		setModal(true);
		setDecorated(false);
		setResizable(false);
		setOpacity(0.5);
		setBorderWidth(1);

		getScreen().getDisplay().getMonitorAtWindow(getWindow()).getWorkarea(workarea);
		if (config.minWidth <= 0)
			config.minWidth = to!int(workarea.width * 0.7);

		setDefaultSize(config.minWidth, 0);
		setPosition(GtkWindowPosition.CENTER_ALWAYS);

		auto text = new Entry(config.text);
		text.overrideBackgroundColor(GtkStateFlags.NORMAL, new RGBA(0.0, 0.0, 0.0, 0.5));
		text.setHasFrame(false);
		text.modifyFont(config.font, config.fontSize);
		text.setAlignment(0.5f);
		add(text);

		text.addOnChanged(delegate void(EditableIF e) {
			string str = text.getText();
			
			double difference = (config.fontSize / 2.0) * min((str.length - 10.0) / 50.0, 1.0);
			text.modifyFont(config.font, to!int(config.fontSize - (str.length > 10 ? difference : 0)));

			int width, height;
			text.createPangoLayout(str).getPixelSize(width, height);

			int newWidth = max(width + 16, config.minWidth);
			if (newWidth >= workarea.width - 16) {
				resize(workarea.width - 16, height);
				text.setAlignment(0f);
			} else {
				resize(newWidth, height);
				text.setAlignment(0.5f);
			}
		});

		text.addOnKeyPress(delegate bool(GdkEventKey* event, Widget w) {
			// select text on Ctrl key press
			// See: https://gitlab.gnome.org/GNOME/gtk/blob/master/gdk/gdkkeysyms.h
			//      https://gtk-d.dpldocs.info/gtk.Widget.Widget.addOnKeyPress.1.html
			if (event.keyval == 0xffe3 || event.keyval == 0xffe4) {
				text.selectRegion(0, -1);
			}

			return false;
		});

		showAll();
	}

}

int main(string[] args) {
	Config config;
	auto opt = getopt(
		args,
		"text", "Preset text to display", &config.text,
		"width", "Minimum width of the popup", &config.minWidth,
		"font", "The system font to use", &config.font
	);

	if (opt.helpWanted) {
		defaultGetoptPrinter("announcer - 0.0.1\n  https://github.com/fennifith/announcer\n", opt.options);
		return 0;
	}

	auto application = new Application("me.jfenn.announce", GApplicationFlags.FLAGS_NONE);
	application.addOnActivate(delegate void(GioApplication app) {
		new Announcer(application, config);
	});
	return application.run(args);
}
