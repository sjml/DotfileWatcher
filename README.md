![DotfileWatcher log](DotfileWatcher/Assets.xcassets/AppIcon.appiconset/appicon_256.png)

# DotfileWatcher

You can download a compiled version from [the latest release](https://github.com/sjml/DotfileWatcher/releases/latest).

Watches a designated directory (default: `~/.dotfiles`) and pops an icon in
the status bar if anything's changed that hasn't been committed to git. From
the icon, you can open the watched directory with the app of your choice (default: 
Finder).

Throw it in Login Items and let it do its thing.

Could be set up to be more configurable, but it does what I need. Note that it just polls the directory every minute instead of watching for changes so it can pop more immediately. The file watching API is annoying; one-minute polling is easy. Here we are. 
