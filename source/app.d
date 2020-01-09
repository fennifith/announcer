import gio.Application : GioApplication = Application;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Entry;

class Announcer : ApplicationWindow {

	this(Application application, string presetText) {
		super(application);
		setTitle("Announce");
		setKeepAbove(true);
		setModal(true);
		setOpacity(0.5);
		setBorderWidth(1);
		setDefaultSize(1000, 0);

		auto text = new Entry(presetText);
		text.setHasFrame(false);
		text.modifyFont("default", 50);
		text.setAlignment(0.5f);
		add(text);

		showAll();
	}

}

int main(string[] args) {
	auto application = new Application("me.jfenn.announce", GApplicationFlags.FLAGS_NONE);
	application.addOnActivate(delegate void(GioApplication app) {
		new Announcer(application, args.length > 1 ? args[1] : "");
	});
	return application.run(args);
}
