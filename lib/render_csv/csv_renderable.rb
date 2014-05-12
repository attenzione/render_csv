require 'csv'

module RenderCsv
  module CsvRenderable
    # Converts an array to CSV formatted string
    # Options include:
    # :only => [:col1, :col2] # Specify which columns to include, also affect on column order
    # :except => [:col1, :col2] # Specify which columns to exclude
    # :add_methods => [:method1, :method2] # Include addtional methods that aren't columns
    def to_csv(options = {})
      return '' if empty?
      return join(',') unless first.class.respond_to? :column_names

      columns = options[:only] ? options[:only].map(&:to_s) : first.class.column_names
      columns -= options[:except].map(&:to_s) if options[:except]
      columns += options[:add_methods].map(&:to_s) if options[:add_methods]

      CSV.generate(encoding: 'utf-8') do |row|
        row << columns
        self.each do |obj|
          row << columns.map { |c| options[c.to_sym].respond_to?(:call) ? obj.instance_exec(&options[c.to_sym]) : obj.send(c) }
        end
      end
    end
  end
end
