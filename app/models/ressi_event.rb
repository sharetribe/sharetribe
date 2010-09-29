class RessiEvent < ActiveResource::Base
  self.site = APP_CONFIG.ressi_url
  self.timeout = APP_CONFIG.ressi_timeout
  self.element_name = "service_event"
end
