# Base serializer with common functionality
class ApplicationSerializer < ActiveModel::Serializer
  # Common date formatting
  def formatted_date(date)
    date&.strftime('%Y-%m-%d %H:%M:%S')
  end
  
  # Helper to exclude nil values from serialized data
  def filter_attributes
    attributes.reject { |_, value| value.nil? }
  end
end