module Recaptcha
  module ClientHelper
    # Your public API can be specified in the +options+ hash or preferably
    # the environment variable +RECAPTCHA_PUBLIC_KEY+.
    def recaptcha_tags(options = {})
      # Default options
      key   = options[:public_key] ||= ENV['RECAPTCHA_PUBLIC_KEY']
      raise RecaptchaError, "No public key specified." unless key
      error = options[:error] ||= (defined? flash ? flash[:recaptcha_error] : "")
      uri   = options[:ssl] ? RECAPTCHA_API_SECURE_SERVER : RECAPTCHA_API_SERVER
      html  = ""
      if options[:display]
        html << %{<script type="text/javascript">\n}
        html << %{  var RecaptchaOptions = #{options[:display].to_json};\n}
        html << %{</script>\n}
      end
      if options[:ajax]
        html << %{<div id="dynamic_recaptcha"></div>}
        html << %{<script type="text/javascript" src="#{uri}/js/recaptcha_ajax.js"></script>\n}
        html << %{<script type="text/javascript">\n}
        html << %{  Recaptcha.create('#{key}', document.getElementById('dynamic_recaptcha')#{options[:display] ? ',RecaptchaOptions' : ''});}
        html << %{</script>\n}
      else
        html << %{<script type="text/javascript" src="#{uri}/challenge?k=#{key}}
        html << %{#{error ? "&error=#{CGI::escape(error)}" : ""}"></script>\n}
        unless options[:noscript] == false
          html << %{<noscript>\n  }
          html << %{<iframe src="#{uri}/noscript?k=#{key}" }
          html << %{height="#{options[:iframe_height] ||= 300}" }
          html << %{width="#{options[:iframe_width]   ||= 500}" }
          html << %{frameborder="0"></iframe><br/>\n  }
          html << %{<textarea name="recaptcha_challenge_field" }
          html << %{rows="#{options[:textarea_rows] ||= 3}" }
          html << %{cols="#{options[:textarea_cols] ||= 40}"></textarea>\n  }
          html << %{<input type="hidden" name="recaptcha_response_field" value="manual_challenge">}
          html << %{</noscript>\n}
        end
      end
      return raw html
    end # recaptcha_tags
  end # ClientHelper
end # Recaptcha
