module OnboardingViewUtils

  STEPS = [:slogan_and_description,
           :cover_photo,
           :filter,
           :paypal,
           :listing,
           :invitation]

  module_function

  def next_incomplete_step(setup_status)
    incomplete_steps = setup_status.reduce(Set.new) do |incomplete, (step, status)|
      if !status
        incomplete.add(step)
      else
        incomplete
      end
    end

    STEPS.find { |s| incomplete_steps.include?(s) }
  end

  def sorted_steps(setup_status)
    STEPS.map { |s| {step: s, complete: setup_status[s]} }
  end

end
