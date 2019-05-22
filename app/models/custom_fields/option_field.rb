# == Schema Information
#
# Table name: custom_fields
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  sort_priority  :integer
#  search_filter  :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  community_id   :integer
#  required       :boolean          default(TRUE)
#  min            :float(24)
#  max            :float(24)
#  allow_decimals :boolean          default(FALSE)
#  entity_type    :integer          default("for_listing")
#  public         :boolean          default(FALSE)
#  assignment     :integer          default("unassigned")
#
# Indexes
#
#  index_custom_fields_on_community_id   (community_id)
#  index_custom_fields_on_search_filter  (search_filter)
#

class OptionField < CustomField
  has_many :options, :class_name => "CustomFieldOption", :dependent => :destroy, :foreign_key => 'custom_field_id'

  # attributes structure:
  #
  # {
  #   <option_id>: {
  #     title_attributes: {
  #       <locale>: <translation>,
  #       ...
  #     },
  #     sort_priority: <prio>
  #   },
  #   ...
  # }
  #
  def option_attributes=(attributes)
    options_hash = options.includes(:titles).map { |option|
      {
        id: option.id,
        sort_priority: option.sort_priority,
        title_attributes: option.titles.map { |title|
          [title.locale, title.value]
        }.to_h
      }
    }

    attributes_hash = attributes.map { |opts|
      {
        id: str_to_integer(opts[:id]),
        sort_priority: opts[:sort_priority].to_i,
        title_attributes: opts[:title_attributes]
      }
    }

    diff = ArrayUtils.diff_by_key(options_hash, attributes_hash, :id)

    Maybe(diff.select { |d| d[:action] == :added }.map { |added| added[:value] }).each { |added|
      options.build(added)
    }

    Maybe(diff.select { |d| d[:action] == :removed }.map { |removed| removed[:value][:id] }).each { |removed_ids|
      options.where(id: removed_ids).destroy_all
    }

    diff.select { |d| d[:action] == :changed }.map { |added| added[:value] }.each { |changed|
      options.where(id: changed[:id]).first.update_attributes(changed)
    }
  end

  def str_to_integer(s)
    if s.nil?
      nil
    elsif !/\A\d+\z/.match(s)
      # not positive integer
      nil
    else
      s.to_i
    end
  end
end
