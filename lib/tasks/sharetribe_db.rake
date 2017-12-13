namespace :sharetribe do
  namespace :db do

    DEFAULT_MIGRATION_DEFINITION = {
      "run" => "auto",
      "stage" => "pre-deploy"
    }

    def run?(migration_definition, stage)
      migration_definition["run"] == "auto" && migration_definition["stage"] == stage
    end

    def migration_definition(migration_definitions, migration)
      migration_definitions[migration.version] || DEFAULT_MIGRATION_DEFINITION
    end

    def definition_weight(definition)
      case [definition["run"], definition["stage"]]
      when matches(["auto", "pre-deploy"])
        1
      when matches(["auto", "post-deploy"])
        2
      when matches(["manual", __])
        3
      else
        10
      end
    end

    def safe_sequence?(migrations, migration_definitions)
      seq = migrations.map do |m|
        definition = migration_definition(migration_definitions, m)
        definition_weight(definition)
      end
      seq.sort() == seq
    end

    def pending_migrations
      migration_paths = ActiveRecord::Migrator.migrations_paths
      all_migrations = ActiveRecord::Migrator.migrations(migration_paths)
      migrator = ActiveRecord::Migrator.new(:up, all_migrations, ActiveRecord::Migrator.last_migration.version())
      migrator.pending_migrations()
    end

    # Run DB migrations automatically for the given execution stage (pre-deploy, post-deploy)
    # based on definitions in db/migration_automation.yml.
    # Stops at the first manual migration or the first migration of a different execution stage.
    task :migrate, [:stage] => :environment do |t, args|
      allowed_stages = ["pre-deploy", "post-deploy"]

      stage = args[:stage] || "pre-deploy"
      raise StandardError.new("Unknown execution stage #{stage}") unless allowed_stages.include?(stage)

      puts "Current database version: #{ActiveRecord::Migrator.current_version()}"
      puts "Last available version: #{ActiveRecord::Migrator.last_migration.version()}"

      pending_migrations = pending_migrations()

      if pending_migrations.empty?
        puts "No pending migrations."
      else
        puts "Migrating..."

        migration_definitions = {}
        File.open("db/migration_automation.yml", File::RDONLY) do |f|
          migration_definitions = YAML.load(f.read())["migrations"]
        end

        # Check if the pending sequence of migrations is supported.
        # E.g. this is not supported sequence: pre-deploy, post-deploy, pre-deploy, ...
        unless safe_sequence?(pending_migrations, migration_definitions)
          puts "The pending migration sequence is not supported!"
          puts "Please, deploy appropriate intermediate version first, or migrate manually!"
          raise StandardError.new("Unsupported migration sequence")
        end

        pending_migrations.each do |migration|
          definition = migration_definition(migration_definitions, migration)

          if run?(definition, stage)
            puts "Running migration #{migration.version}"

            ActiveRecord::Migrator.up(ActiveRecord::Migrator.migrations_paths, migration.version)
          else
            puts "Automatic migration for #{stage} execution stage stopping at migration version #{migration.version}."
            break
          end
        end
      end
    end

    namespace :migrate do
      # Make sure there are no pending migrations. Exit with failure otherwise.
      task :ensure_latest => [:environment] do |t, args|
        unless pending_migrations().empty?
          puts "There are pending migrations!"
          raise StandardError.new("There are pending migrations!")
        end
      end
    end
  end
end
