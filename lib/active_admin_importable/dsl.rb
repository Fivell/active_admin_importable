module ActiveAdminImportable
  module DSL

    def active_admin_importable(date_format=nil)
      action_item :only => :index do
        link_to "Import #{active_admin_config.resource_name.to_s.pluralize}", :action => 'import'
      end

      collection_action :import, :method => :get do
        render "admin/import"
      end

      collection_action :process_import, :method => :post do
        unless params[:import]
          flash[:alert] = "You should choose file for import"
          redirect_to :back
        end

        extension =
            case params[:import]['file'].content_type
              when 'text/csv'
                'csv'

            end

        unless extension.in? %w{csv}
          flash[:alert] = "You can import file only with extension csv"
          redirect_to :back
        end
        begin
          result = Importer.import extension, active_admin_config.resource_class, params[:import][:file], :date_format => date_format
          flash[:notice] = "Imported #{result[:imported]} #{active_admin_config.resource_name.downcase.send(result[:imported] == 1 ? 'to_s' : 'pluralize')}"

          unless result[:failed] == 0
            to_notify = ["Failed to import #{result[:failed]} #{active_admin_config.resource_name.downcase.send(result[:failed] == 1 ? 'to_s' : 'pluralize')}", result[:errors]]
            to_notify.join(' : ')
            flash[:error] = to_notify
          end

        rescue StandardError=>e

          flash[:error] = e.message
        end

        redirect_to :back
      end

    end
  end
end
