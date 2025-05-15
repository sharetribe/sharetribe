module Admin2::Emails
  class OutgoingEmailsController < Admin2::AdminBaseController

    before_action :ensure_white_label_plan, only: %i[create]

    def index
      @url_params = {
        host: @current_community.full_domain,
        ref: 'welcome_email',
        locale: @current_user.locale,
        protocol: APP_CONFIG.always_use_ssl.to_s == 'true' ? 'https://' : 'http://'
      }

      sender_address = EmailService::API::API.addresses.get_sender(community_id: @current_community.id).data
      user_defined_address = EmailService::API::API.addresses.get_user_defined(community_id: @current_community.id).data
      ses_in_use = EmailService::API::API.ses_client.present?

      enqueue_status_sync!(user_defined_address)

      resend_url = Maybe(user_defined_address).map { |address|
        resend_verification_email_admin2_emails_outgoing_emails_path(address_id: address[:id])
      }.or_else(nil)

      render 'index', locals: {
        status_check_url: check_email_status_admin2_emails_outgoing_emails_path,
        resend_url: resend_url,
        support_email: APP_CONFIG.support_email,
        sender_address: sender_address,
        user_defined_address: user_defined_address,
        post_sender_address_url: admin2_emails_outgoing_emails_path,
        can_set_sender_address: can_set_sender_address(@current_plan),
        ses_in_use: ses_in_use,
        show_branding_info: !@current_plan[:features][:whitelabel]
      }
    end

    def create
      user_defined_address = EmailService::API::API.addresses.get_user_defined(community_id: @current_community.id).data

      if user_defined_address && user_defined_address[:email] == params[:email].to_s.downcase.strip
        EmailService::API::API.addresses.update(community_id: @current_community.id, id: user_defined_address[:id], name: params[:name])
        render json: { message: t('admin2.outgoing_address.successfully_saved_name') }
        return
      end

      res = EmailService::API::API.addresses.create(
        community_id: @current_community.id,
        address: {
          name: params[:name],
          email: params[:email]
        })

      if res.success
        render json: { message: t('admin2.outgoing_address.successfully_saved') }
      else
        error_message =
          case Maybe(res.data)[:error_code]
          when Some(:invalid_email)
            t('admin2.outgoing_address.invalid_email_error', email: res.data[:email])
          when Some(:invalid_email_address)
            t('admin2.outgoing_address.invalid_email_address')
          when Some(:invalid_domain)
            kb_link = view_context.link_to(t('admin2.outgoing_address.invalid_email_domain_read_more_link'), "#{APP_CONFIG.knowledge_base_url}/#heading=h.nyzqn09g7ne3", class: "flash-error-link") # rubocop:disable Layout/LineLength
            t('admin2.outgoing_address.invalid_email_domain', email: res.data[:email], domain: res.data[:domain], invalid_email_domain_read_more_link: kb_link).html_safe
          else
            t('admin2.outgoing_address.unknown_error')
          end

        raise error_message
      end
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

    def check_email_status
      res = EmailService::API::API.addresses.get_user_defined(community_id: @current_community.id)

      if res.success
        address = res.data

        if params[:sync]
          enqueue_status_sync!(address)
        end

        render json: HashUtils.camelize_keys(address.merge(translated_verification_sent_time_ago: time_ago(address[:verification_requested_at])))
      else
        render json: { error: res.error_msg }, status: :internal_server_error
      end
    end

    def resend_verification_email
      EmailService::API::API.addresses.enqueue_verification_request(community_id: @current_community.id, id: params[:address_id])
      render layout: false
    end

    private

    def enqueue_status_sync!(address)
      Maybe(address)
        .reject { |addr| addr[:verification_status] == :verified }
        .each { |addr|
          EmailService::API::API.addresses.enqueue_status_sync(
            community_id: addr[:community_id],
            id: addr[:id])
        }
    end

    def ensure_white_label_plan
      unless can_set_sender_address(@current_plan)
        flash[:error] = t('admin2.outgoing_address.not_in_plan')
        redirect_to action: :index
      end
    end

    def can_set_sender_address(plan)
      plan[:features][:admin_email]
    end
  end
end
