TEMPLATE = '.git_template'
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

