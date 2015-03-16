class AppDelegate
  attr_accessor :client

  # iOS
  def application(application, didFinishLaunchingWithOptions: launch_options)
    # window.makeKeyAndVisible
    # authorize
    true
  end

  # OS X
  def applicationDidFinishLaunching(notification)
    # window_controller.showWindow(self)
    # authorize
    true
  end

  def authorize
    MotionAuth.authorize(:digitalocean) do |auth_data, error|
      return mp "Error: #{error.localizedDescription}" if error
      mp auth_data
    end
  end

  # iOS main window
  # @return [UIWindow]
  def window
    @window ||= begin
      window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      window.backgroundColor = UIColor.lightGrayColor
      window.rootViewController = UIViewController.new
      window
    end
  end

  # OS X window controller
  # @return [NSWindowController]
  def window_controller
    @window_controller ||= begin
      window_controller = UIWindowController.new
      window_controller.window = UIWindow.alloc.initWithContentRect(
        [[0, 0], [300, 200]],
        styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask,
        backing:   NSBackingStoreBuffered,
        defer:     false
      )
      window_controller.window.title = "Hello World"
      window_controller
    end
  end
end
