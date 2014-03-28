module StylesheetCompiler
  class << self

    # Compile SASS files at runtime using Sprockets.
    #
    # Replace SASS variables on fly by pointing the variable file and
    # providing key/value hash of variable names/values
    #
    # params:
    # - `source_dir`    Path to SASS files
    # - `source_file`   Sprockets manifest file (usually application.css)
    # - `target_file`   Path for target file
    # - `variable_file` File where variables are (relative to `source_dir`)
    # - `variabhe_hash` Hash for variable values.
    #    `key` is SASS variable name without dollar ($)
    #    `value` the new value (including optional quotes ("), excluding ;)
    #
    # examples params:
    # - `source_dir`: "app/assets/stylesheets"
    # - `source_file`: "application.scss"
    # - `target_file`: "public/assets/blue-links.css.gz"
    # - `variable_file`: "colors.scss"
    # - `variable_hash`: {link_color: "#0000FF"}
    #
    def compile(source_dir, source_file, target_file, variable_file, variable_hash={})
      in_work_dir(source_dir) do |work_dir|
        replace_variables("#{work_dir}/#{variable_file}", variable_hash)
        sprockets_compile(work_dir, source_file, target_file)
      end
    end

    private

    def create_sprockets_env(path)
      Sprockets::Environment.new(Rails.root).tap do |env|
        env.append_path path
        env.append_path Kassi::Application::VENDOR_CSS_PATH

        env.context_class.instance_eval do
          # Include these helpers to allow SASS files to use image-url etc. helpers
          include Sprockets::Helpers::RailsHelper
          include Sprockets::Helpers::IsolatedHelper

          def sass_config
            ActiveSupport::OrderedOptions.new.tap do |s|
              compass = Compass::Frameworks['compass']

              s.load_paths = [
                compass.stylesheets_directory,
                compass.templates_directory
              ]

              # Here we can add SASS configurations
              s.style = :compressed
            end
          end
        end
      end
    end

    def sprockets_compile(work_dir, source, target)
      sprockets = create_sprockets_env(work_dir)
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
