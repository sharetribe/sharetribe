module OnboardingViewUtils

  STEPS = [:slogan_and_description,
           :cover_photo,
           :filter,
           :payment,
           :listing,
           :invitation]

  CELEBRATIONS = {
    slogan_and_description: "onboarding/success_rocket@2x.png",
    cover_photo: "onboarding/success_magicWand@2x.png",
    filter: "onboarding/success_music@2x.png",
    payment: "onboarding/success_ufo@2x.png",
    listing: "onboarding/success_party@2x.png",
    invitation: "onboarding/success_hotairballoon@2x.png",
    all_done: "onboarding/success_mountain@2x.png"}

  module_function

  def incomplete_steps(setup_status)
    setup_status.reduce(Set.new) do |incomplete, (step, status)|
      if !status
        incomplete.add(step)
      else
        incomplete
      end
    end
  end

  def next_incomplete_step(setup_status)
    incomplete_steps = incomplete_steps(setup_status)
    STEPS.find { |s| incomplete_steps.include?(s) } || :all_done
  end

  def sorted_steps(setup_status)
    STEPS.map { |s| {step: s, complete: setup_status[s]} }
  end

  def sorted_steps_with_includes(setup_status, includes = {})
    STEPS.map { |s| {step: s, complete: setup_status[s]}.merge(includes[s] || {}) }
  end

  def celebration_image(next_step)
    CELEBRATIONS[next_step]
  end

  def guide_link(guide_base_path, step)
    if step == :all_done
      guide_base_path
    else
      "#{guide_base_path}/#{step}"
    end
  end

  def popup_locals(show_popup, guide_base_path, setup_status)
    if show_popup
      next_step = next_incomplete_step(setup_status)

      {show_onboarding_popup: true,
       popup_title_key: "admin.onboarding.popup.#{next_step}.title",
       popup_body_key: "admin.onboarding.popup.#{next_step}.body",
       popup_button_key: "admin.onboarding.popup.#{next_step}.button",
       popup_image: celebration_image(next_step),
       popup_action_link: guide_link(guide_base_path, next_step)}
    else
      {show_onboarding_popup: false}
    end
  end

  def progress(setup_status)
    total_steps = STEPS.count + 1 # We always have step 1 "Create marketplace" completed
    completed_steps = total_steps - incomplete_steps(setup_status).count
    100 * (completed_steps/total_steps.to_f)
  end

end
