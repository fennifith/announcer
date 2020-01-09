import std.stdio: writeln;
import std.getopt;
import std.algorithm.comparison : min, max;
import std.math : log;
import std.conv: to;
import gio.Application : GioApplication = Application;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Entry;
import gtk.EditableIF;
import gtk.c.types : GtkStateFlags, GtkWindowPosition;
import gdk.RGBA;

struct Config {
	string text;
	int minWidth = 700;
	string font = "default";
}

class Announcer : ApplicationWindow {

	this(Application application, Config config) {
		super(application);
		setTitle("Announce");
		setKeepAbove(true);
		setModal(true);
		setDecorated(false);
		setResizable(false);
		setOpacity(0.5);
		setBorderWidth(1);
		setDefaultSize(config.minWidth, 0);
		setPosition(GtkWindowPosition.CENTER_ALWAYS);

		auto text = new Entry(config.text);
		text.overrideBackgroundColor(GtkStateFlags.NORMAL, new RGBA(0.0, 0.0, 0.0, 0.5));
		text.setHasFrame(false);
		text.modifyFont(config.font, 70);
		text.setAlignment(0.5f);
		add(text);

		text.addOnChanged(delegate void(EditableIF e) {
			string str = text.getText();
			if (str.length < 40)
				text.modifyFont(config.font, to!int(15*log(50 - str.length) + 10));

			int width, height;
			text.createPangoLayout(str).getPixelSize(width, height);
			resize(max(width + 16, config.minWidth), height);
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
