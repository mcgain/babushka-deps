dep "vim" do
  requires ["packages", "languages", "vim-source", "vim-config"]

  met? {
    requirements
  }

  meet {
    compile && install
  }
end

def requirements
  return false unless "vim/src/vim".p.exists?
  result = true
  cd "vim" do
      require 'pry-byebug'
      binding.pry
    vim_version = shell("src/vim --version")
    %w(+python +ruby +conceal).each do |feature|
      result &= vim_version.include?(feature)
    end
    result &= shell("src/vim --version").include?("VIM - Vi IMproved 7.4")
  end
  result
end

def compile
  cd "vim" do
    shell("make distclean")
    shell("./configure " + options)
    shell("make")
  end
end

def install
  cd "vim" do
    shell("sudo make install")
    shell("sudo mv /usr/bin/vim /usr/bin/vim.original.system")
    shell("sudo ln -s /usr/local/bin/vim /usr/bin/vim")
  end
end

def options
  [
    "--with-features=HUGE",
    "--enable-multibyte=yes",
    "--enable-cscope=yes",
    "--enable-fontset",
    "--enable-rubyinterp",
    "--with-ruby-command=/opt/boxen/rbenv/shims/ruby",
    "--enable-pythoninterp",
    "--with-python-config-dir=/usr/lib/python2.6/config"
  ].join(" ")
end

#"--with-ruby-command=/home/mcgain/.rvm/rubies/ruby-1.9.3-p286/bin/ruby",
dep "vim-config" do
  met? {
    open("~/.vimrc") { |f| f.each_line.detect { |line| /Richard McGain's Dotfiles/.match(line) } }
  }

  meet {
    cd "~" do
      shell("git clone git@github.com/mcgain/dotfiles.git")
      shell("mv dotfiles/* .")
    end
  }
end

dep "vim-source" do
  requires "mercurial.bin"
  met? {
    "vim/Vim.info".p.exists?
  }

  meet {
    shell("hg clone https://vim.googlecode.com/hg/ vim")
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
