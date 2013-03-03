# Wordpress::Tools

Created to simplify initial setup for a Wordpress project.

With a a simple command you can have all boilerprate necessary for you wordpress-site.
See [Usage](#usage) for know how to use.

## Installation

Add this line to your application's Gemfile:

    gem 'wordpress-tools'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wordpress-tools

## <a id="usage"></a>Usage

To init a simple project:

    wp init project-name

for more helpers and actions:

    wp -h
and you should see:

    Usage: wp action [OPTIONS]

    Available actions:
    init

    Example: wp init <main_theme_name> [OPTIONS]
            --wordpress-version=[WORDPRESS_VERSION]
                                         Wordpress Version to use. Default: latest
            --skip-wordpress             Skips wordpress download (Assumes an existing wordpress site)

    Common options:
        -v, --version                    Show the program version
        -V, --verbose
            --dry-run
        -c, --class-prefix CLASS_PREFIX  Prefix for all theme-related classes
        -h, --help                       Print this message



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
