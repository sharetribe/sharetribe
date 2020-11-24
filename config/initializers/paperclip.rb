Paperclip::UriAdapter.register
Paperclip::DataUriAdapter.register
Paperclip::HttpUrlProxyAdapter.register

module Paperclip
  Attachment.class_eval do
    def assign(uploaded_file)
      @file = Paperclip.io_adapters.for(uploaded_file,
                                        @options[:adapter_options])
      ensure_required_accessors!
      ensure_required_validations!

      if @file.assignment?
        clear(*only_process)

        if @file.nil?
          nil
        else
          assign_attributes
          convert_heic_to_well_known_image
          post_process_file
          reset_file_if_original_reprocessed
        end
      else
        nil
      end
    end

    private

    def convert_heic_to_well_known_image
      return unless ['image/heic', 'image/heif'].include?(@file.content_type)
      style = Paperclip::Style.new(:original_png, ["#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>", :png], self)
      post_process_style(:original, style)
      reset_file_if_original_reprocessed
      instance_write(:file_name, "#{@file.original_filename}.png")
      instance_write(:content_type, "image/png")
    end
  end
end

