set :application, "Kassi"
set :repository,  "svn+ssh://alpha.sizl.org/svn/kassi/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/datat/kassi"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "alpha.sizl.org"
role :web, "alpha.sizl.org"
role :db,  "alpha.sizl.org", :primary => true

set :use_sudo, false