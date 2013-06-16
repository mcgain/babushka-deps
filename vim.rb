dep "vim" do
  requires ["packages", "languages", "vim-source", "vim-config"]

  met? {
    requirements
  }

  meet {
    compile #&& install
  }
end

def requirements
  return false unless "vim/src/vim".p.exists?
  cd "vim" do
    shell("src/vim --version").include?("+python")
  end
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
  end
end

def options
  [
  "--with-features=HUGE",
  "--enable-multibyte=yes",
  "--enable-cscope=yes",
  "--enable-fontset",
  "--enable-rubyinterp",
  "--with-ruby-command=/home/mcgain/.rvm/rubies/ruby-1.9.3-p286/bin/ruby",
  "--enable-pythoninterp",
  "--with-python-config-dir=/usr/lib/python2.6/config"
  ].join(" ")
end

  dep "vim-config" do

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
  end

  dep 'ncurses.lib' do
    installs {
      via :apt, 'libncurses5-dev', 'libncursesw5-dev'
      via :brew, 'ncurses'
    }
  end

  dep "languages" do
    requires ["ruby", "python"]
  end

  dep "python", template: "bin" do
    installs "python-dev"
    provides "python"
  end
