class RessiEvent < ActiveResource::Base
  self.site = RESSI_URL
  self.timeout = RESSI_TIMEOUT
  self.element_name = "service_event"
end
