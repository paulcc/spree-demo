require 'activerecord'

namespace :demo do
  # Specialized version of bootstrap that can be run in production mode (since this is just a demo.)  
  desc "Migrate schema to version 0 and back up again. WARNING: Destroys all data in tables!!"
  task :remigrate => :environment do
    # Drop all tables
    ActiveRecord::Base.connection.tables.each { |t| ActiveRecord::Base.connection.drop_table t }
    # Migrate upward 
    Rake::Task["db:migrate"].invoke      
    # Dump the schema
    Rake::Task["db:schema:dump"].invoke
  end
  
  # Specialized version of bootstrap that can be run in production mode (since this is just a demo.)  
  desc "Bootstrap your database for Spree."
  task :bootstrap  => :environment do
    ENV['AUTO_ACCEPT'] = 'yes'
    ENV['SKIP_NAG'] = 'yes'

    # Remigrate
    Rake::Task["db:remigrate"].invoke
  
    require 'spree/setup'
      
    attributes = {
      :admin_password => "spree",
      :admin_email => "spree@example.com"          
    }
    Spree::Setup.bootstrap attributes
  end
end

namespace :db do
  desc "Bootstrap your database for Spree."
  task :bootstrap  => :environment do
    # load initial database fixtures (in db/sample/*.yml) into the current environment's database
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    Dir.glob(File.join(SiteExtension.root, "db", 'sample', '*.{yml,csv}')).each do |fixture_file|
      Fixtures.create_fixtures("#{SiteExtension.root}/db/sample", File.basename(fixture_file, '.*'))
    end
  end
end

namespace :spree do
  namespace :extensions do
    namespace :site do
      desc "Copies public assets of the Site to the instance public/ directory."
      task :update => :environment do
        is_svn_git_or_dir = proc {|path| path =~ /\.svn/ || path =~ /\.git/ || File.directory?(path) }
        Dir[SiteExtension.root + "/public/**/*"].reject(&is_svn_git_or_dir).each do |file|
          path = file.sub(SiteExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end