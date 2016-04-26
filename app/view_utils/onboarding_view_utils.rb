module OnboardingViewUtils

  STEPS = [:slogan_and_description,
           :cover_photo,
           :filter,
           :paypal,
           :listing,
           :invitation]

  CELEBRATIONS = {
    slogan_and_description: "onboarding/success_rocket@2x.png",
    cover_photo: "onboarding/success_magicWand@2x.png",
    filter: "onboarding/success_music@2x.png",
    paypal: "onboarding/success_ufo@2x.png",
    listing: "onboarding/success_party@2x.png",
    invitation: "onboarding/success_hotairballoon@2x.png",
    all_done: "onboarding/success_mountain@2x.png"}

  module_function

  def next_incomplete_step(setup_status)
    incomplete_steps = setup_status.reduce(Set.new) do |incomplete, (step, status)|
      if !status
        incomplete.add(step)
      else
        incomplete
      end
    end

    STEPS.find { |s| incomplete_steps.include?(s) } || :all_done
  end

  def sorted_steps(setup_status)
    STEPS.map { |s| {step: s, complete: setup_status[s]} }
  end

  def celebration_image(next_step)
    CELEBRATIONS[next_step]
  end

end
