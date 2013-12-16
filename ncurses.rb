  dep 'ncurses.lib' do
    installs {
      via :brew, 'ncurses'
      via :apt, 'libncurses5-dev', 'libncursesw5-dev'
    }
  end
