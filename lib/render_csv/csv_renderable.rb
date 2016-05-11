require 'csv'

module RenderCsv
  module CsvCustomRenderable
    # Converts an array to CSV formatted string
    # Options include:
    # :only => [:col1, :col2] # Specify which columns to include, also affect on column order
    # :except => [:col1, :col2] # Specify which columns to exclude
    # :add_methods => [:method1, :method2] # Include addtional methods that aren't columns
    # other options key could be used for custom columns with value as lambda
    def to_custom_csv(options = {})
      return '' if empty?
      return join(',') unless first.class.respond_to? :column_names

      options = { separator: ',', force_quotes: false, force_excel_separator: false }.merge(options)

      columns = options[:only] ? options[:only] : first.class.column_names
      columns -= options[:except] if options[:except]
      columns += options[:add_methods] if options[:add_methods]

      CSV.generate(encoding: 'utf-8', col_sep: options[:separator], force_quotes: options[:force_quotes]) do |rows|

        if options[:force_excel_separator]
          rows << ["sep=#{options[:sep]}"]
        end

        # first row
        rows << columns.map { |v| v.is_a?(Hash) ? v.values.first.to_s : v.to_s }

        self.each do |obj|
          rows << columns.map do |column|

            column = column.keys.first if column.is_a?(Hash)

            if options[column.to_sym].respond_to?(:call)
              obj.instance_exec(&options[column.to_sym])
            elsif obj.respond_to?(column)
              obj.send(column)
            elsif options[:method_missing].respond_to?(:call)
              options[:method_missing].call(obj, column)
            else
              obj.send(column)
            end

          end
        end
      end
    end
  end
end
