class SmerfGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false
  
  attr_accessor :plugin_path
  attr_accessor :user_model_name, :user_table_name, :user_table_fk_name 
  attr_accessor :link_table_name, :link_table_fk_name, :link_table_model_name,
                :link_table_model_class_name, :link_table_model_file_name

  def initialize(runtime_args, runtime_options = {})
    super

    @user_model_name = @name.downcase()
    @user_table_name = @name.pluralize()
    @user_table_fk_name = "#{@user_model_name}_id"
    
    if (("smerf_forms" <=> @user_table_name) <= 0)
      @link_table_name = "smerf_forms_#{@user_table_name}"
    else
      @link_table_name = "#{@user_table_name}_smerf_forms"
    end
    @link_table_fk_name = "#{@link_table_name.singularize()}_id"
    @link_table_model_name = @link_table_name.singularize()
    @link_table_model_class_name = @link_table_model_name.classify()
    @link_table_model_file_name = @link_table_model_name.underscore()
    
    @plugin_path = "vendor/plugins/smerf"
  end
 
  def manifest
    record do |m|
      
      # Migrations
      m.migration_template("migrate/create_smerfs.rb", 
        "db/migrate", {:migration_file_name => 'create_smerfs'}) unless options[:skip_migration]

      # Routes
      m.route_resources(:smerf_forms)

      # Create smerf directory and copy test form
      m.directory('smerf')
      m.file('smerf/testsmerf.yml', 'smerf/testsmerf.yml')
      
      # Copy example stylesheet
      m.file('public/smerf.css', 'public/stylesheets/smerf.css')

      # Copy error and help images
      m.file('public/smerf_error.gif', 'public/images/smerf_error.gif')
      m.file('public/smerf_help.gif', 'public/images/smerf_help.gif')
      
      # Helpers
      m.file 'lib/smerf_helpers.rb', 'lib/smerf_helpers.rb'
      
      # Copy models
      m.template('app/models/smerf_forms_user.rb', "#{plugin_path}/app/models/#{@link_table_model_file_name}.rb")
      m.template('app/models/smerf_response.rb', "#{plugin_path}/app/models/smerf_response.rb")
      
      # Copy controllers
      m.template('app/controllers/smerf_forms_controller.rb', "#{plugin_path}/app/controllers/smerf_forms_controller.rb")

      # init.rb
      m.file('smerf_init.rb', "#{plugin_path}/init.rb", :collision => :force)

      # Display INSTALL notes
      m.readme "INSTALL"
    end
  end
  
  protected
  
    # Custom banner
    def banner
      "Usage: #{$0} smerf UserModelName"
    end
    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration files") { |v| options[:skip_migration] = v }
    end

end
