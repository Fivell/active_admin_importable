module ActiveAdminImportable
  module Importer
    def self.import extension, resource, file, options={}
      result = {imported: 0, failed: 0, errors: [""]}
      data =
        case extension
          when 'csv'
            self::CSV.parse file

        end

      if data[:header]
        data[:header].map! { |el| el.underscore.gsub(/\s+/, '_') }
      end

      attributes = resource.attribute_names
      attr_accessible = resource.attr_accessible[:default]
      restricted_attributes = ['id', 'created_at', 'updated_at']

      data[:data].each_with_index do |line, line_index|
        row = {}

        line.each_with_index do |value, cell_index|
          attribute = data[:header][cell_index]

          if attribute.in?(restricted_attributes) || !attribute.in?(attributes) || !attribute.in?(attr_accessible)
            next
          end

          if value && [:date, :datetime].include?(resource.columns_hash[attribute].type)
            row[attribute] = options[:date_format] ? Date.strptime(value, options[:date_format]) : Chronic.parse(value)
          else
            row[attribute] =  value.nil? ? nil : value.to_s.encode('UTF-8', :undef => :replace, :invalid => :replace)
          end
        end

        new_resource = resource.new(row)
        if  new_resource.save
          result[:imported] += 1
        else
          result[:failed] += 1
          new_resource.errors.messages.each do |k,v|
            v.each do |em|
              result[:errors] << k.to_s + ':' + em + ' ' 
            end
          end
        end
      end

      result
    end

  end
end
