dep 'gosu.lib' do
  installs {
    via :apt, 'libsdl2-dev',
      'libsdl2-ttf-dev',
      'libpango1.0-dev',
      'libgl1-mesa-dev',
      'libfreeimage-dev',
      'libopenal-dev',
      'libsndfile-dev'
    via :brew, 'sdl2', 'libogg', 'libvorbis'
  }
end
