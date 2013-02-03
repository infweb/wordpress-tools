$rsync_opts = %w(-avz --progress)
$remote_site = "infweb@infweb.web805.uni5.net:~/www"
$local_site = File.expand_path("..", __FILE__)
$theme_name = "infweb"

def rsync(from, to, opt=$rsync_opts)
  cmd = "rsync #{opt.join(" ")} #{from} #{to}"
  puts "Executing command \"#{cmd}\""
  out = %x|#{cmd}|
  puts out if ENV['VERBOSE']
  out
end

namespace :sync do
  desc "Sync plugins down to the local site"
  task :plugins do
    rsync "#{$remote_site}/wp-content/plugins/",
          "#{$local_site}/wp-content/plugins/"
  end

  desc "Sync down theme specified by $THEME"
  task :theme do
    theme = ENV['THEME']
    raise "You must specify a theme passed by THEME env var." if theme.nil?
    rsync "#{$remote_site}/wp-content/themes/#{theme}",
          "#{$local_site}/wp-content/themes/#{theme}"
  end
end

desc "Deploy the local copy to the website"
task :deploy do
  rsync "#{$local_site}/wp-content/themes/#{$theme_name}/",
        "#{$remote_site}/wp-content/themes/#{$theme_name}/"
end

desc "Bootstrap the app, downloading the latest wordpress to the current directory"
task :bootstrap do
  puts "TODO"
end

namespace :deploy do
  desc "Deploy the latest versions of plugins to the live website"
  task :plugins do
    delete_remote = ENV['DELETE'].to_s == "yes"
    extra_options = $rsync_opts.dup

    extra_options << "--delete" if delete_remote

    rsync "#{$local_site}/wp-content/plugins/",
          "#{$remote_site}/wp-content/plugins/",
          extra_options
  end
end