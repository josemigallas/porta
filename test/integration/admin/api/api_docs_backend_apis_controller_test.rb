# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApiDocsBackendApisControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @backend_api = FactoryBot.create(:backend_api, account: @provider)

    login! @provider
    host! @provider.admin_domain
  end

  def test_create_sets_all_attributes
    assert_difference ::ApiDocs::Service.method(:count) do
      post admin_api_backend_api_active_docs_path(api_docs_params(backend_api_id: @backend_api.id, system_name: 'smart_service'))
      assert_response :created
    end

    api_docs_backend_api = @provider.all_api_docs.last!
    assert_equal 'smart_service', api_docs_backend_api.system_name
    assert_equal @backend_api.id, api_docs_backend_api.owner_id
    assert_equal 'BackendApi', api_docs_backend_api.owner_type
    assert_equal @provider.id, api_docs_backend_api.account_id
  end

  def test_update_with_right_params
    api_docs_backend_api = FactoryBot.create(:api_docs_service, account: @provider, owner: @backend_api)
    update_params = api_docs_params(id: api_docs_backend_api.id, name: 'test-update')
    put admin_api_backend_api_active_doc_path(api_docs_backend_api), update_params
    assert_response :success

    api_docs_backend_api.reload
    assert_equal 'test-update', api_docs_backend_api.name
  end

  def test_system_name_is_not_updated
    api_docs_backend_api = FactoryBot.create(:api_docs_service, account: @provider, owner: @backend_api)
    origin_system_name = api_docs_backend_api.system_name
    update_params = api_docs_params(id: api_docs_backend_api.id, system_name: 'test-update-system-name')
    put admin_api_backend_api_active_doc_path(api_docs_backend_api), update_params
    assert_response :success

    api_docs_backend_api.reload
    assert_not_equal 'test-update-system-name', api_docs_backend_api.system_name
    assert_equal origin_system_name, api_docs_backend_api.system_name
  end

  def test_update_invalid_params
    api_docs_backend_api = FactoryBot.create(:api_docs_service, account: @provider, owner: @backend_api)
    old_body = api_docs_backend_api.body
    update_params = api_docs_params(id: api_docs_backend_api.id, body: '{apis: []}')
    put admin_api_backend_api_active_doc_path(api_docs_backend_api), update_params
    assert_response :unprocessable_entity

    api_docs_backend_api.reload
    assert_match 'JSON Spec is invalid', response.body
    assert_equal old_body, api_docs_backend_api.body
  end

  private

  def api_docs_params(additional_params = {})
    { 
      api_docs_backend_api: {
        name: 'update_servone',
        body: '{"apis": [{"foo": "bar"}], "basePath": "http://example.net"}',
        description: 'updated description',
        published: '1',
        skip_swagger_validations: '0'
      }.merge(additional_params)
    }
  end
end
