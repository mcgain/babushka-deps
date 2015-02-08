dep "vim" do
  requires %w(packages languages vim-source vim-build vim-install vim-config)
end

dep "vim-build" do
  met? {
    cd "/tmp/vim" do
      "src/vim".p.exists? && has_desired_features?(shell("src/vim --version"))
    end
  }
  meet {
    cd "/tmp/vim" do
      shell("make distclean")
      shell("./configure " + options)
      shell("make")
    end
  }
end

dep "vim-install" do
  met? {
    vim_version = shell("vim --version")
    has_desired_features?(vim_version)
  }
  meet {
    cd "/tmp/vim" do
      shell("sudo make install")
      shell("sudo mv /usr/bin/vim /usr/bin/vim.original.system")
      shell("sudo ln -s /usr/local/bin/vim /usr/bin/vim")
    end
  }
end

def has_desired_features?(vim_version)
  %w(7.4 Huge +python +ruby +conceal).all? do |feature|
    vim_version.include?(feature)
  end
end

def options
  [
    "--with-features=huge",
    "--enable-multibyte=yes",
    "--enable-cscope=yes",
    "--enable-fontset",
    "--enable-rubyinterp",
    "--with-ruby-command=#{`which ruby`.chomp}",
    "--enable-pythoninterp",
    "--with-python-config-dir=/usr/lib/python2.6/config"
  ].join(" ")
end

#"--with-ruby-command=/home/mcgain/.rvm/rubies/ruby-1.9.3-p286/bin/ruby",

dep "vim-source" do
  requires "mercurial.bin"
  met? {
    cd "/tmp/vim" do
      "Vim.info".p.exists?
    end
  }

  meet {
    shell("hg clone https://vim.googlecode.com/hg/ /tmp/vim")
  }
end

dep "mercurial.bin" do
  provides "hg"
end

dep "packages" do
  requires ['ncurses.lib', 'mac', 'ubuntu.lib']
end

dep "mac" do
  if Babushka::SystemDetector.profile_for_host.osx?
    requires ['docutils.pip']
  end
end

dep "docutils.pip" do
  installs 'docutils'
  provides 'rst2html.py'
end

dep "ubuntu.lib" do
  installs { via :apt, "libgnome2-dev" }
  installs { via :apt, "libgnomeui-dev" }
  installs { via :apt, "libgtk2.0-dev" }
  installs { via :apt, "libatk1.0-dev" }
  installs { via :apt, "libbonoboui2-dev" }
  installs { via :apt, "libcairo2-dev" }
  installs { via :apt, "libx11-dev" }
  installs { via :apt, "libxpm-dev" }
  installs { via :apt, "libxt-dev" }
  installs { via :apt, "libpython2.7-dev" }
end

dep 'ncurses.lib' do
  installs {
    via :brew, 'ncurses'
    via :apt, 'libncurses5-dev', 'libncursesw5-dev'
  }
end

dep "languages" do
  requires ["ruby", "python"]
end

dep "python", template: "bin" do
  installs "python-dev"
  provides "python"
end
