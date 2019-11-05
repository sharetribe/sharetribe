class ListingsChannel < ApplicationCable::Channel
  def follow
    stream_from 'listings'
  end
end
