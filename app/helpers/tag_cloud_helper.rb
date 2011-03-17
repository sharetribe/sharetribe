module TagCloudHelper
  def tag_cloud(tags, classes)
    result = Hash.new()
    max, min = 0, 0
    tags.each { |t|
      max = t.count.to_i if t.count.to_i > max
      min = t.count.to_i if t.count.to_i < min
    }

    divisor = ((max - min) / classes.size) + 1

    tags.each { |t|
      result[t.name] = classes[(t.count.to_i - min) / divisor]
    }
    return result.sort
  end
end
