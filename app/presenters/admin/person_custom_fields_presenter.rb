class Admin::PersonCustomFieldsPresenter
  attr_reader :community, :params, :min_option_count, :custom_field

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def new_custom_field
    field = build_resource
    default_options(field)
    @custom_field = field
  end

  def find_custom_field
    @custom_field = resorce_scope.find(params[:id])
    default_min_option_count(custom_field)
    custom_field
  end

  def custom_fields
    resorce_scope
  end

  def create
    field = build_resource
    field.assign_attributes(custom_field_params)
    field.sort_priority = resorce_scope.max_priority.last.priority.to_i + 1
    @custom_field = field
    resorce_scope << field
  end

  def update
    find_custom_field
    custom_field.update_attributes(custom_field_params)
  end

  def order
    sort_priorities = params[:order].map(&:to_i)
    resorce_scope.each do |field|
      field.update_attributes(sort_priority: sort_priorities.index(field.id))
    end
  end

  def destroy
    find_custom_field
    custom_field.destroy
  end

  def show_custom_fields?
    custom_fields.any?
  end

  def number_min
    0
  end

  def number_max
    9999
  end

  def new_option
    CustomFieldOption.new
  end

  def edit?
    custom_field.persisted?
  end

  private

  def resorce_scope
    community.person_custom_fields
  end

  def build_resource
    if CustomField::VALID_TYPES.include?(params[:field_type])
      field = params[:field_type].constantize.new
      field.entity_type = :for_person
      field
    end
  end

  def custom_field_params
    permitted = params.require(:custom_field)
      .permit(:required, :min, :max, :allow_decimals,
              name_attributes: {},
              option_attributes: [:id, :sort_priority, title_attributes: {}])
    [:min, :max].each do |key|
      permitted[key] = ParamsService.parse_float(permitted[key]) if permitted[key].present?
    end
    permitted
  end

  def default_options(custom_field)
    default_min_option_count(custom_field)
    checkbox = custom_field.is_a?(CheckboxField)
    custom_field.options = if checkbox
                             [CustomFieldOption.new(sort_priority: 1)]
                           else
                             [CustomFieldOption.new(sort_priority: 1), CustomFieldOption.new(sort_priority: 2)]
                           end
  end

  def default_min_option_count(custom_field)
    checkbox = custom_field.is_a?(CheckboxField)
    @min_option_count = if checkbox
                          1
                        else
                          2
                        end
  end
end

