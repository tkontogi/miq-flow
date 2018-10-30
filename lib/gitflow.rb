module GitFlow
  def self.init()
    # prepare directories
    #
    $tmpdir = Dir.mktmpdir('miq_import_')
    Dir.mkdir(File.join($tmpdir, 'repo'))
    Dir.mkdir(File.join($tmpdir, 'import'))

    # configure logging
    #
    $logger  = Logger.new(STDOUT)
    $logger.level = $default_opts.fetch(:log_level, Logger::INFO)

    # get git repository
    #
    prepare_repo($default_opts[:git_opts])
  end
  def self.tear_down()
    FileUtils::rm_rf($tmpdir) if $default_opts[:clear_tmp] == true
  end
  def self.validate()
    raise "No git repository specified" if $git_url.nil? and $git_path.nil?
  end

  

  def self.process_environment_variables()
    $git_url      = ENV['GIT_URL']
    $git_user     = ENV['GIT_USER']
    $git_password = ENV['GIT_PASSWORD']
    $git_path     = ENV['GIT_PATH']

    $default_opts[:log_level] = Logger::DEBUG if ENV['VERBOSE'] == 'true'
    $default_opts[:log_level] = Logger::WARN  if ENV['QUIET'] == 'true'

    $default_opts[:clear_tmp] = false  if ENV['CLEAR_TMP'] == 'false'
  end

  def self.prepare_repo(opts)
    clone_repo(opts) unless $git_url.nil?
    local_repo(opts) unless $git_path.nil?
  end
  def self.clone_repo(opts)
    $logger.info("Cloning git Repository from: #{$git_url}")
    dir = File.join($tmpdir, 'repo')

    # make Credentials
    opts[:credentials] = Rugged::Credentials::UserPassword.new(username: $git_user, password: $git_pssword) if $git_user and $git_password

    $git_repo = Rugged::Repository.clone_at($git_url, dir, opts)
    raise "Failed to clone repository at #{$git_url}" if $git_repo.nil?
  end
  def self.local_repo(opts)
    $logger.info("Using git Repository: #{$git_path}")
    $git_repo = Rugged::Repository.discover($git_path, opts.fetch(:accross_fs, true))
    raise "Failed to clone repository at #{$git_path}" if $git_repo.nil?
  end
end
