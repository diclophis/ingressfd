MRuby::Build.new do |conf|
  # load specific toolchain settings
  toolchain :gcc

  enable_debug

  conf.bins = ["mrbc"]

  conf.gem :core => "mruby-bin-mirb"
  conf.gem :core => "mruby-string-ext"
  conf.gem :git => "git@github.com:mattn/mruby-uv", :branch => "master"
  conf.gem :git => "git@github.com:Asmod4n/mruby-phr", :branch => "master"
  conf.gem :git => "git@github.com:Asmod4n/mruby-tls", :branch => "master"
  conf.gem :git => 'git@github.com:mattn/mruby-base64.git', :branch => 'master'
  conf.gem :git => 'git@github.com:iij/mruby-iijson', :branch => 'master'

  conf.cc do |cc|
    cc.flags = ['-I"../libressl/include"'] #ENV['CFLAGS'] || [] #, "-lm"].join(" ")
  end
end
