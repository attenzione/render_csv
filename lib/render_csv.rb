module RenderCsv
  class RenderCsvRailtie < ::Rails::Railtie
    config.after_initialize do
      require 'render_csv/csv_renderable'
      require 'action_controller/metal/renderers'

      ActionController.add_renderer :csv do |csv, options|
        filename = options[:filename] || options[:template]
        csv.extend RenderCsv::CsvCustomRenderable
        data = csv.to_custom_csv(options)
        send_data data, type: "#{Mime[:csv].to_s}; charset=utf-8; header=present", disposition: "attachment; filename=#{filename}.csv"
      end
    end
  end
end
