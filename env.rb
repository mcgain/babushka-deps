dep 'env' do
  requires 'matcher'
  requires 'vim'
  requires 'vim-config'
  requires 'dotfiles'
  requires 'ag.bin'
end

dep 'vim' do
  met? {
    output = shell 'vim --version'
    output =~ /Vi IMproved 7.4/
  }
  meet {
    puts "you're on your own"
  }
end

dep 'vim-config' do
  requires ['dotfiles', 'vundle']
end

dep 'vundle' do
  requires 'vundle.repo'
  met? {
    cd '' do
      regex = /Plugin\s+'[\w-]*\/(.*)'/
      plugins = []
      File.open('.vimrc').readlines.grep(regex){plugins << $1}
      plugins.map!{|x|x = x.gsub(/\.git/,'')}
      installed_plugins = Dir.glob('.vim/bundle/*').entries.map{|x|x= x.split('/').last}
      (plugins - installed_plugins).empty?
    end
  }
  meet {
    shell('git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim')
    shell('vim +PluginInstall +qall')
  }
end

dep 'vundle.repo' do
  met? {
    cd '' do
      cd '.vim/bundle' do
        Babushka::GitRepo.new('Vundle.vim').exists?
      end
    end
  }
  meet {
    shell('git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim')
  }
end

dep 'ag.bin' do
  installs 'silversearcher-ag'
  provides 'ag'
end

dep 'dotfiles' do
  requires 'dotfiles.repo'
  met? {
    cd "" do
      dotfiles.all? do |name|
        File.exists?(name)
      end
    end
  }
  meet {
    cd "" do
      shell "mkdir old-dotfiles" unless File.exists?('old-dotfiles')
      dotfiles.each do |name|
        shell "mv #{name} old-dotfiles/#{name}" if File.exists?(name)
        shell "mv /tmp/dotfiles/#{name} ."
      end
    end
  }
end

def dotfiles
  Dir.entries('/tmp/dotfiles') - ['..', '.']
end

dep 'dotfiles.repo' do
  met? {
    cd '/tmp' do
      Babushka::GitRepo.new('dotfiles').exists?
    end
  }
  meet {
    cd '/tmp' do
      repo = Babushka::GitRepo.new('dotfiles')
      repo.clone!('https://github.com/mcgain/dotfiles')
    end
  }
end

dep 'matcher' do
  requires 'matcher.repo'
  met? {
    shell "matcher -v" do |s|
      s.stderr =~ /matcher\: invalid option -- 'v'/
    end
  }
  meet {
    cd '/tmp' do
      cd 'matcher' do
        shell 'make'
        sudo 'make install'
      end
    end
  }
end

dep 'matcher.repo' do
  met? {
    cd '/tmp' do
      Babushka::GitRepo.new('matcher').exists?
    end
  }
  meet {
    cd '/tmp' do
      repo = Babushka::GitRepo.new('matcher')
      repo.clone!('https://github.com/burke/matcher.git')
    end
  }
end
