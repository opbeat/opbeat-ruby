namespace :opbeat do
  desc "Notifies Opbeat of new releases"
  task :notify do
    on roles(:app) do

      scm = fetch(:scm)
      if scm.to_s != "git"
        info "Skipping Opbeat release because scm is not git."
        next
      end

      rev = fetch(:current_revision)
      branch = fetch(:branch, 'master')

      within release_path do
        with rails_env: fetch(:rails_env), rev: rev, branch: branch do
          capture :rake, 'opbeat:release'
        end
      end
    end
  end
end

namespace :deploy do
  after :publishing, "opbeat:notify"
end
