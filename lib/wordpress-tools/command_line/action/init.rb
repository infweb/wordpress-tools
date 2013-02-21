module Wordpress::Tools::CommandLine::Action
  class Init < Base
    def run!
      if args.empty?
        raise "You must specify a main theme name."
      end

      config.update :theme_name => args.first

      unless options[:skip_wordpress]
        path = download_wp
        untar_wp(path, target_directory) 
      end

      bootstrap_theme(target_directory, main_theme_name)

      %w(build.xml build.properties).each do |t|
        render_template "#{t}.erb", "#{target_directory}/#{t}", :theme_name => main_theme_name
      end

      config.save("#{target_directory}/config.yml") unless dry_run?
      add_to_vcs(target_directory)
    end

    private

    def bootstrap_theme(target_dir, theme_name)
      theme_path = "#{target_dir}/wp-content/themes/#{theme_name}"
      classes_path = "#{theme_path}/classes"
      templates_path = "#{theme_path}/templates"
      helpers_path = "#{theme_path}/helpers"
      assets_path = "#{theme_path}/assets"

      [classes_path, templates_path, helpers_path, assets_path].each do |dir|
        create_directory dir
      end

      render_template "functions.php.erb", "#{theme_path}/functions.php", 
                      :theme_name => theme_name, :class_prefix => options[:class_prefix]

      render_template "theme_class.php.erb", "#{classes_path}/#{options[:class_prefix]}Theme.class.php",
                      :theme_name => theme_name, :class_prefix => options[:class_prefix]

      %w(index header footer).each do |f|
        copy_file "#{f}.php", "#{theme_path}/#{f}.php"
      end

      render_template "style.css.erb", File.join(theme_path, "style.css"), :theme_name => theme_name
      cd_into(assets_path) { run "compass create ." }
    end

    def add_to_vcs(path)
      cd_into path do
        run "git init ."
        copy_file "main_gitignore", "#{path}/.gitignore"
        
        render_template "themes_gitignore.erb", "#{File.dirname(theme_path)}/.gitignore", 
                      :theme_name => main_theme_name
        copy_file("plugins_gitignore", "#{target_directory}/wp-content/plugins/.gitignore")
      end
    end

    def untar_wp(from, to)
      wp_src_dir = "#{File.dirname(from)}/wordpress"

      cmd = "tar -xz#{ "v" if verbose?}f #{from} -C #{File.dirname(from)}"
      run cmd
      run "mv -v #{wp_src_dir} #{to}"
    end

    def download_wp
      tmp = Tempfile.new('wp')
      puts "Downloading Wordpress from #{wp_download_link}..." if verbose?

      if dry_run?
        return "/some/dummy/path/for/wp"
      else
        open(wp_download_link) do |io|
          tmp << io.read
          tmp.path
        end
      end
    end

    def wp_download_link
      "http://br.wordpress.org/#{options[:wp_version]}-pt_BR.tar.gz"
    end

    # Utility Methods
    def main_theme_name; config.theme_name; end
    def theme_path
      "#{target_directory}/wp-content/themes/#{main_theme_name}"
    end
    def target_directory
      @target_directory ||= File.expand_path("#{main_theme_name}")
    end
  end
end