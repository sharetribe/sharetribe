module StringUtils
  module_function

  def trim_and_hide(str_to_hide, num_visible=2)
    trimmed = (str_to_hide || "").strip
    asterisks = (trimmed.length - 1) - num_visible
    (0..asterisks).inject("") { |a, _| a + "*" } + trimmed.last(num_visible)
  end

  def first_words(str, word_count=15)
    str.nil? ? "" : str.split(" ").take(word_count).join(" ")
  end

  # this is a text -> this text (letter_count: 2)
  def strip_small_words(str, min_letter_count=2)
    str.split(" ").select { |word| strip_punctuation(word).length > min_letter_count }.join(" ")
  end

  def strip_punctuation(str)
    str.gsub(/[^[[:word:]]\s]/, '')
  end

  def strip_nbsp(str)
    str.gsub("&nbsp;", "")
  end

  def keywords(str, word_count=10, min_letter_count=3)
    strip_punctuation(first_words(strip_small_words(strip_nbsp(str), min_letter_count), word_count)).downcase.split(" ").join(", ")
  end

  def is_numeric?(str)
    !!str.match(/\A\d+\z/)
  end
end
