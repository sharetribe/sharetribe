module SpecUtils
  # Give `arr` and `needle_arr` and get back
  # true if all elements of `needle_arr` are included in `arr`
  #
  # http://stackoverflow.com/questions/7387937/ruby-rails-how-to-determine-if-one-array-contains-all-elements-of-another-array
  def include_all?(arr, needle_arr)
    (needle_arr - arr).empty?
  end
end