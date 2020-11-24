# ThinkingSphinx::Deltas::DelayedDelta::DeltaJob

def stub_thinking_sphinx
  allow(ThinkingSphinx::Deltas::DelayedDelta::DeltaJob).to receive(:perform).and_return(true)
  allow(ThinkingSphinx::Deltas::IndexJob).to receive(:perform).and_return(true)
end

