# frozen_string_literal: true

class Admin::ApiDocs::AccountApiDocsController < Admin::ApiDocs::BaseController
  activate_menu :audience, :cms, :ActiveDocs
  sublayout 'api/service'

  class NotImplementedServiceScopeError < RuntimeError; end
  rescue_from(NotImplementedServiceScopeError) do |exception|
    System::ErrorReporting.report_error(exception)
    handle_not_found
  end

  before_action :redirect_to_service_scope, if: :service, only: %i[edit preview]

  def index
    @api_docs_services = api_docs_collection.page(params[:page])
  end

  private

  def redirect_to_service_scope
    flash.keep
    case action_name.to_sym
    when :preview
      redirect_to preview_admin_service_api_doc_path(service, api_docs_service)
    when :edit
      redirect_to edit_admin_service_api_doc_path(service, api_docs_service)
    else
      raise NotImplementedServiceScopeError, "#{action_name} redirection for ApiDoc under Service scope is not implemented"
    end
  end

  def service
    return if api_docs_service.owner_type != 'Service'

    api_docs_service.owner
  end

  def find_api_docs
    @api_docs_service = api_docs_collection.find_by_id_or_system_name!(params[:id])
  end

  def current_scope
    current_account
  end

  def api_docs_collection
    current_scope.all_api_docs
  end
end
