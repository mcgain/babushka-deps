require 'pry-byebug'

dep 'env' do
  requires 'matcher'
  requires 'vim'
  requires 'vim-config'
  requires 'dotfiles'
  requires 'ag.bin'
  requires 'ctags'
  requires 'selecta'
end

dep 'ctags' do
  requires 'ctags.bin'
  met? {
    %w(post-commit post-merge post-checkout post-rewrite)
      .map { |f| File.join(Dir.pwd, '.git_template', 'hooks', f) }
      .all? { |f| File.exists?(f) }
  }
  meet {
    dir = File.join(Dir.home, '.git_template')
    Dir.mkdir(dir) unless Dir.exists?(dir)
    FileUtils.cp_r(File.join(File.expand_path(File.dirname(__FILE__)), 'git_template', 'hooks'), dir)
  }
end

dep 'ctags.bin' do
  installs 'exuberant-ctags'
  provides 'ctags'
end

dep 'vim-config' do
  requires ['dotfiles', 'vundle']
end

dep 'vundle' do
  requires 'vundle.repo'
  met? {
    cd '~' do
      regex = /Plugin\s+'[\w-]*\/(.*)'/
      plugins = []
      File.open('.vimrc').readlines.grep(regex){plugins << $1}
      plugins.map!{|x|x = x.gsub(/\.git/,'')}
      installed_plugins = Dir.glob('.vim/bundle/*').entries.map{|x|x= x.split('/').last}
      (plugins - installed_plugins).empty?
    end
  }
  meet {
    shell('vim +PluginInstall +qall')
  }
end

dep 'vundle.repo' do
  met? {
    cd '~/.vim/bundle' do
      Babushka::GitRepo.new('Vundle.vim').exists?
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

dep 'selecta' do
  requires 'selecta.repo'
  met? {
    shell("selecta -v") >= '0.0.6'
  }
  meet {
    cd '/tmp' do
      cd 'selecta' do
        'selecta'.to_fancypath.cp('~/bin/selecta'.to_fancypath)
      end
    end
  }
end

dep 'selecta.repo' do
  met? {
    cd '/tmp' do
      Babushka::GitRepo.new('selecta').exists?
    end
  }
  meet {
    cd '/tmp' do
      repo = Babushka::GitRepo.new('selecta')
      repo.clone!('https://github.com/selecta/selecta.git')
    end
  }
end
