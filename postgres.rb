dep 'postgres.bin' do
  installs ['postgresql', 'libpq-dev', 'postgresql-contrib']
  provides "psql ~> 9.3.0"
end
