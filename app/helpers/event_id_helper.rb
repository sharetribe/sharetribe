module EventIdHelper

  # USE NOTATION #(params[:key]) in here to insert param values in the string
  # ONLY #(params[:]) are changed in here

  EVENTS_HASH = {
    "people"  => {
      "show" => "show_profile_page_of_#(params[:id])",
      "home" => "show_front_page",
      "index" => "show_people_list_page_#(params[:page])_per_page_#(params[:per_page])",
      "search" => "people_search",
      "more_kassi_events" => "get_more_kassi_events_for_front_page",
      "more_content_items" => "get_more_content_items_for_front_page",
      "create" => "create_new_user",
      "new" => "show_user_register_form",
      "update" => "update_profile",
      "send_message" => "sending_message",
    },
    "groups" => {
      "show" => "show_group_details_of_#(params[:id])",
      "index" => "show_groups_list_page_#(params[:page])_per_page_#(params[:per_page])",
      "search" => "groups_search",
      "create" => "create_new_group",
      "new" => "show_group_form",
      "update" => "update_group",
      "join" => "joining_group_#(params[:id])",
      "leave"  => "leave_group_#(params[:id])",
    },
    "sessions" => {
      "forgot_password" => "forgot_password",

    }
  }

  def self.generate_event_id(params)

    ## THE EVENT_HASH is stored as a constant and the replacements are done only if needed.
    ## not sure if that really is faster than just doing all the replacements anyway, but maybe a little.. :)

    if EVENTS_HASH[params[:controller]] && EVENTS_HASH[params[:controller]][params[:action]]
      event_string = EVENTS_HASH[params[:controller]][params[:action]]
      regexp_to_match = /#\(params\[:([^\]]+)\]\)/
      while (event_string =~ regexp_to_match) do
        key = event_string[regexp_to_match, 1]
        replace_value = params[key] || ""
        event_string.sub!(/#\(params\[:#{key}\]\)/, replace_value)
      end
    else
      event_string = "unlabeled_event"
      if (params[:controller] && params[:action])
        event_string = "#{params[:controller]}::#{params[:action]}"

      end
    end
    return event_string
  end
end
