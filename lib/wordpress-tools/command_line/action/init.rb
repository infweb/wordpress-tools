module Wordpress::Tools::Action
  class Init < Base
    def run!
      if args.empty?
        raise "You must specify a main theme name."
      end

      unless options[:skip_wordpress]
        path = download_wp
        untar_wp(path, target_directory) 
      end

      bootstrap_theme(target_directory, main_theme_name)
      add_to_vcs(target_directory)

      %w(build.xml build.properties).each do |t|
        render_template "#{t}.erb", "#{target_directory}/#{t}", :theme_name => main_theme_name
      end
    end

    private

    def bootstrap_theme(target_dir, theme_name)
      theme_path = "#{target_dir}/wp-content/themes/#{theme_name}"
      classes_path = "#{theme_path}/classes"
      FileUtils.mkdir_p(classes_path)
      render_template "functions.php.erb", "#{theme_path}/functions.php"), 
                      :theme_name => theme_name, :class_prefix => options[:class_prefix]

      render_template "theme_class.php.erb", "#{classes_path}/#{options[:class_prefix]}Theme.class.php",
                      :theme_name => theme_name, :class_prefix => options[:class_prefix]

      render_template "style.css.erb", File.join(theme_path, "style.css"), :theme_name => theme_name
      run "cd #{theme_path}; compass create ."
    end

    def add_to_vcs(path)
      current = FileUtils.pwd
      begin
        FileUtils.cd(path)
        run "git init ."
        copy_file "main_gitignore", "#{path}/.gitignore"
        
        render_template "themes_gitignore.erb", "#{File.dirname(theme_path)}/.gitignore", 
                      :theme_name => main_theme_name
        copy_file("plugins_gitignore", "#{target_directory}/wp-content/plugins/.gitignore")
      ensure
        FileUtils.cd(current)
      end
    end

    def untar_wp(from, to)
      wp_src_dir = File.join File.dirname(from), "wordpress"

      cmd = "tar -xzvf #{from} -C #{File.dirname(from)}"
      puts "Running #{cmd}..."
      run cmd
      run "mv -v #{wp_src_dir} #{to}"
    end

    def download_wp
      tmp = Tempfile.new('wp')
      puts "Downloading Wordpress from #{wp_download_link}..."
      open(wp_download_link) do |io|
        tmp << io.read
        tmp.path
      end
    end

    def wp_download_link
      "http://br.wordpress.org/#{options[:wp_version]}-pt_BR.tar.gz"
    end

    # Utility Methods
    def main_theme_name; args.first; end
    def target_directory
      File.expand_path("#{main_theme_name}")
    end
  end
end