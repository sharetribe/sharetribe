Kassi::Application.configure do

  str_to_bool = ->(v) {
    if v == true || v == false
      v
    elsif v == "false"
      false
    else
      true
    end
  }

  Maybe(APP_CONFIG.asset_host).each { |asset_host|
    config.action_controller.asset_host = asset_host
  }

  Maybe(APP_CONFIG.eager_load).each { |eager_load|
    config.eager_load = str_to_bool.call(eager_load)
  }

end
