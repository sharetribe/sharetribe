module StylesheetCompiler
  class << self

    # Compile SASS files at runtime using Sprockets.
    #
    # params:
    # - `source_dir`    Path to SASS files
    # - `source_file`   Sprockets manifest file (usually application.css)
    # - `target_file`   Path for target file
    # - `variable_file` File where the replacable variables are (relative to `source_dir`)
    # - `variabhe_hash` Hash for variable values.
    #    `key` is SASS variable name without dollar ($)
    #    `value` the new value (including optional quotes ("), excluding ;)
    #
    # examples params:
    # - `source_dir`: "app/assets/stylesheets"
    # - `source_file`: "application.scss"
    # - `target_file`: "public/assets/custom-marketplace-styles.css.gz"
    # - `variable_file`: "colors.scss"
    # - `variable_hash`: {link_color: "#0000FF"}
    #
    # More detailed explanation about the compilation process:
    #
    # Rails' asset pipeline (which is powered by Sprockets) is somewhat tightly coupled
    # to the Controller/View layer. However, in some cases, like compiling custom stylesheets
    # in background job, we need to use Sprockets outside the Controller/View context.
    # That's not super easy thing to do and that's why this module may seem a bit black magic.
    #
    # The compilation process has the following phases:
    #
    # ## 1. Copy the whole `source_dir` to a temporary direction, e.g. `work_dir`
    #
    # In the next step we will replace some content in the directory. We want to do it in
    # isolation and that's why we make the temporary copy of the directory.
    #
    # ## 2. Replace SCSS variables
    #
    # Open the `variable_file` and replace the SCSS variables with those that are given in
    # `variable_hash`. Do the replacement in that file.
    #
    # ## 3. Create a Sprockets environment
    #
    # From sprockets documentation:
    #
    # > You'll need an instance of the Sprockets::Environment
    # class to access and serve assets from your application. Under Rails 4.0 and later,
    # YourApp::Application.assets is a preconfigured Sprockets::Environment instance.
    #
    # We will use the preconfigured Sprockets environment to compile the assets. However,
    # we need to do one change to the existing environment. We need to remove the `source_dir`
    # from the environment `paths` and replace it with the `work_dir`. That's how we can use
    # the newly created copy of the source dir.
    #
    # The `Rails.application.assets` can be either a Sprockets::Environment or an immutable
    # Sprockets::Index (in production). Because we need to make changes to the `paths` we need
    # to use the mutable Sprockets::Environment. We can fetch the environment from the
    # Sprockets::Index by getting the @environment instance variable.
    #
    # Read more:
    # http://matteodepalo.github.io/blog/2013/01/31/how-to-create-custom-stylesheets-dynamically-with-rails-and-sass/
    #
    # Warning! We will change the Rails.application.assets which is a globally mutable value.
    # This is very dangerous! Do not run this method in the server process!
    #
    # ## 4. Compile and write to file
    #
    # After setting up the Sprockets environment for compilation, we will compile the file
    # and write it to the filesystem.
    #
    def compile(source_dir, source_file, target_file, variable_file, variable_hash={})
      in_work_dir(source_dir) do |work_dir|
        replace_variables("#{work_dir}/#{variable_file}", variable_hash)
        sprockets_compile(source_dir, work_dir, source_file, target_file)
      end
    end

    private

    def create_sprockets_env(source_dir, work_dir)
      env = get_sprockets_env()

      paths_without_source_dir = env.paths.reject { |p| p.include?(source_dir) }
      paths_with_work_dir = [work_dir] + paths_without_source_dir

      env.clear_paths

      paths_with_work_dir.each { |p|
        env.append_path p
      }

      env
    end

    def get_sprockets_env
      if Rails.application.assets.is_a?(Sprockets::Index)
        # Production
        Rails.application.assets.instance_variable_get('@environment')
      else
        # Development
        Rails.application.assets
      end
    end

    def sprockets_compile(source_dir, work_dir, source, target)
      sprockets = create_sprockets_env(source_dir, work_dir)
      asset = sprockets[source]
      asset.write_to(target)
    end

    def replace_in_file(file_name, search, replace)
      text = File.read(file_name)
      File.open(file_name, "w") { |f| f.write(text.sub(search, replace)) }

    end

    def replace_variable(file, var_name, value)
      replace_in_file(file, /\$#{var_name}:\s*(.*?);/, "$#{var_name}: #{value};")
    end

    def replace_variables(file, variable_hash)
      variable_hash.each { |variable_name, value| replace_variable(file, variable_name, value) }
    end

    # Create a temporary full copy of the whole CSS folder structure
    def in_work_dir(source_dir)
      in_temp_dir do |temp_dir|
        work_dir = "#{temp_dir}/stylesheets"
        FileUtils.copy_entry(source_dir, work_dir)
        yield work_dir
      end
    end

    def in_temp_dir()
      path = File.expand_path "#{Dir.tmpdir}/#{Time.now.to_i}#{rand(1000)}/"
      FileUtils.mkdir_p path
      yield path
    ensure
      FileUtils.rm_rf( path ) if File.exists?( path )
    end

  end
end
