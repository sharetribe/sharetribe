# Without this fix, downgrading from Rails 4 to Rails 3 causes session cookies to blow up.
#
# The way the flash is stored in the session changed in a backwards-incompatible way.
#
# Credits: https://gist.github.com/henrik/bb6732d5d4cddb5085a4
#
# Remove this when we are sure that we don't need to rollback from 4 to 3.

if Rails::VERSION::MAJOR == 3

  module ActionDispatch
    class Flash
      def call(env)
        if (session = env['rack.session']) && (flash = session['flash'])

          # Beginning of change!

          if flash.respond_to?(:sweep)
            flash.sweep
          else
            session.delete("flash")
          end

          # End of change!

        end

        @app.call(env)
      ensure
        session    = env['rack.session'] || {}
        flash_hash = env[KEY]

        if flash_hash
          if !flash_hash.empty? || session.key?('flash')
            session["flash"] = flash_hash
            new_hash = flash_hash.dup
          else
            new_hash = flash_hash
          end

          env[KEY] = new_hash
        end

        if session.key?('flash') && session['flash'].empty?
          session.delete('flash')
        end
      end
    end
  end

end
