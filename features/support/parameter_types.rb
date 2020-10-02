# frozen_string_literal: true

quoted_list_subpattern = '"[^"]*"(?:(?:,| and) "[^"]*")'

QUOTED_ONE_OR_MORE_PATTERN = "(#{quoted_list_subpattern}*)"
QUOTED_TWO_OR_MORE_PATTERN = "(#{quoted_list_subpattern}+)"
QUOTED_LIST_PATTERN        = QUOTED_ONE_OR_MORE_PATTERN # 1 or more is the default

ParameterType(
  name: 'billing',
  regexp: /(prepaid|postpaid)? ?billing/,
  transformer: ->(mode) do
    if mode && mode == 'prepaid'
      'Finance::PrepaidBillingStrategy'
    else
      'Finance::PostpaidBillingStrategy'
    end
  end
)

ParameterType(
  name: 'list',
  regexp: /^#{QUOTED_LIST_PATTERN}$/,
  transformer: ->(list) { list.from_sentence.map { |item| item.delete('"') } }
)

ParameterType(
  name: 'level',
  regexp: /admin|master/,
  transformer: ->(level) { level }
)

ParameterType(
  name: 'backend_version',
  regexp: /(?:v(\d+)|(oauth))/,
  transformer: ->(version) { version }
)

# Plans

ParameterType(
  name: 'plan_type',
  regexp: /account|service|application/,
  transformer: ->(type) { type }
)

ParameterType(
  name: 'authentication_strategy',
  regexp: /(Janrain|internal|Cas)/,
  transformer: ->(strategy) { strategy }
)

# Accounts

PROVIDER = /(provider ".+?"|master provider)/

ParameterType(
  name: 'account',
  type: Account,
  regexp: /account "([^"]*)"/,
  transformer: ->(org_name) { Account.find_by!(org_name: org_name) }
)

ParameterType(
  name: 'the_provider',
  type: Account,
  regexp: /^the provider$/,
  transformer: ->(_) { @provider or raise ActiveRecord::RecordNotFound, "@provider does not exist" }
)

ParameterType(
  name: 'provider',
  type: Account,
  regexp: /provider "([^"]*)"|(master) provider|provider (master)/,
  transformer: ->(name) do
    # TODO: fix this hacky way of getting master
    if name == 'master'
      Account.master rescue FactoryBot.create(:master_account)
    else
      Account.providers.readonly(false).find_by!(org_name: name)
    end
  end
)

ParameterType(
  name: 'master_provider',
  type: Account,
  regexp: /^(master provider)$/,
  transformer: ->(_) { Account.master }
)

ParameterType(
  name: 'buyer',
  type: Account,
  regexp: /buyer "([^"]*)"/,
  transformer: ->(org_name) { Account.buyers.find_by!(org_name: org_name) }
)

ParameterType(
  name: 'state',
  regexp: /pending|approved|rejected/,
  transformer: ->(state) { state }
)

# Cinstance / Application

ParameterType(
  name: 'user_key_of_buyer',
  regexp: /^user key of buyer "([^"]*)"$/,
  transformer: ->(name) { Account.buyers.find_by!(org_name: name).bought_cinstance.user_key }
)

ParameterType(
  name: 'the application id of buyer',
  regexp: /^the application id of buyer "([^"]*)"$/,
  transformer: ->(name) { Account.buyers.find_by!(org_name: name).bought_cinstance.application_id }
)

ParameterType(
  name: 'application',
  type: Cinstance,
  regexp: /application "([^"]*)"/,
  transformer: ->(name) { Cinstance.find_by!(name: name) }
)

# Potato CMS

ParameterType(
  name: 'cms_page',
  type: CMS::Page,
  regexp: /^"(.+?)"$/i,
  transformer: ->(path) { CMS::Page.find_by!(path: path) }
)

ParameterType(
  name: 'cms_partial',
  type: CMS::Partial,
  regexp: /^"(.+?)"$/i,
  transformer: ->(path) { CMS::Partial.find_by!(system_name: path) }
)

# CMS

# ParameterType(
#   name: 'page',
#   type: Page,
#   regexp: /^"([^\"]*)"$/,
#   transformer: ->(title) { Page.find_by!(title: title) }
# )

ParameterType(
  name: 'page of provider',
  regexp: /^page "([^\"]*)" of provider "([^\"]*)"$/,
  transformer: ->(title, provider_name) do
    provider = Account.providers.find_by!(org_name: provider_name)
    Page.find_by!(title: title, account_id: provider.id)
  end
)

ParameterType(
  name: 'page at of provider',
  regexp: /^page at (.*) of provider "([^\"]*)"$/,
  transformer: ->(path, provider_name) do
    provider = Account.providers.find_by!(org_name: provider_name)
    Page.find_by!(path: path, account_id: provider_id)
  end
)

ParameterType(
  name: 'section of provider',
  regexp: /^section "([^\"]*)" of provider "([^\"]*)"$/,
  transformer: ->(name, provider_name) do
    provider = Account.providers.readonly(false).find_by!(org_name: provider_name)
    provider.provided_sections.find_by!(title: name)
  end
)

ParameterType(
  name: 'html block',
  regexp: /^html block "([^\"]*)"$/,
  transformer: ->(name) { HtmlBlock.find_by!(name: name) }
)

ParameterType(
  name: 'country',
  regexp: /^country "([^"]*)"$/,
  transformer: ->(name) { Country.find_by!(name: name) }
)

ParameterType(
  name: 'feature',
  regexp: /^feature "([^"]*)"$/,
  transformer: ->(name) { Feature.find_by!(name: name) }
)

# Forum

ParameterType(
  name: 'forum',
  regexp: /"([^"]*)"/,
  transformer: ->(name) { Account.providers.find_by!(org_name: name).forum }
)

ParameterType(
  name: 'topic',
  regexp: /^topic "([^\"]+)"$/,
  transformer: ->(name) { Topic.find_by!(title: title) }
)

ParameterType(
  name: 'post',
  regexp: /^post "([^"]*)"$/,
  transformer: ->(body) do
    post = Post.all.to_a.find { |p| p.body == body }
    assert post
    post
  end
)

ParameterType(
  name: 'last post under topic',
  regexp: /^the last post under topic "([^"]*)"$/,
  transformer: ->(title) { Topic.find_by!(title: title).posts.last }
)

ParameterType(
  name: 'category',
  regexp: /^category "([^"]*)"$/,
  transformer: ->(name) { TopicCategory.find_by!(name: name) }
)

# Metric

ParameterType(
  name: 'metric',
  regexp: /metric "([^"]*)"/,
  transformer: ->(name) { Metric.find_by!(system_name: name) }
)

ParameterType(
  name: 'metric_on_application_plan',
  regexp: /metric "([^"]*)" on application plan "([^"]*)"/,
  transformer: ->(metric_name, plan_name) do
    plan = ApplicationPlan.find_by!(name: plan_name)
    plan.metrics.find_by!(system_name: metric_name)
  end
)

ParameterType(
  name: 'metric of provider',
  regexp: /^metric "([^"]*)" of provider "([^"]*)$/,
  transformer: ->(metric_name, provider_name) do
    provider = Account.find_by!(org_name: provider_name)
    provider.first_service!.metrics.find_by!(system_name: name)
  end
)

ParameterType(
  name: 'method',
  regexp: /^method "([^"]*)"$/,
  transformer: ->(name) { current_account.first_service!.metrics.hits.children.find_by!(system_name: name) }
)

ParameterType(
  name: 'plan',
  type: Plan,
  regexp: /plan "([^"]*)"/,
  transformer: ->(name) { Plan.find_by!(name: name) }
)

ParameterType(
  name: 'service',
  type: Service,
  regexp: /service "([^"]*)"/,
  transformer: ->(name) { Service.find_by!(name: name) }
)

# TODO
# ParameterType(
#   name: 'service plan',
#   type: ServicePlan,
#   regexp: /^service plan "(.+?)"$/,
#   transformer: ->(name) { ServicePlan.find_by!(name: name) }
# )

# ParameterType(
#   name: 'account plan',
#   type: AccountPlan,
#   regexp: /^account plan "(.+?)"$/,
#   transformer: ->(name) { AccountPlan.find_by!(name: name) }
# )

# ParameterType(
#   name: 'application plan',
#   type: ApplicationPlan,
#   regexp: /^application plan "(.+?)"$/,
#   transformer: ->(name) { ApplicationPlan.find_by!(name: name) }
# )

ParameterType(
  name: 'user',
  type: User,
  regexp: /"([^"]*)"/,
  transformer: ->(name) { User.find_by!(username: name) }
)

ParameterType(
  name: 'legal terms',
  regexp: /^legal terms "([^\"]*)"$/,
  transformer: ->(name) { CMS::LegalTerm.find_by!(title: name) }
)

ParameterType(
  name: 'group_of',
  regexp: /buyer group "[^"]*" of provider "[^\"]*"/,
  transformer: ->(name, provider_name) { name }
)

ParameterType(
  name: 'table: buyer, name, plans',
  regexp: /^table:buyer,name,plan$/i,
  transformer: ->(table) do
    table.map_headers! {|header| header.parameterize.underscore.downcase.to_s }
    table.map_column!(:buyer) {|buyer| Account.buyers.find_by!(org_name: buyer) }
    table.map_column!(:plan) {|plan| ApplicationPlan.find_by!(name: plan) }
    table
  end
)

ParameterType(
  name: 'table: name, cost per month, setup fee',
  regexp: /^table:name,cost per month,setup fee$/i,
  transformer: ->(table) do
    table.map_headers! {|header| header.parameterize.underscore.downcase.to_s }
    table.map_column!(:cost_per_month) &:to_f
    table.map_column!(:setup_fee) &:to_f
    table
  end
)

ParameterType(
  name: 'table: code, name',
  regexp: /^table:code,name$/i,
  transformer: ->(table) do
    table.map_headers! {|header| header.parameterize.underscore.downcase.to_s }
    table
  end
)

ParameterType(
  name: 'email template',
  regexp: /^email template "(.+?)"$/,
  transformer: ->(name) { CMS::EmailTemplate.find_by!(system_name: name) }
)

ParameterType(
  name: 'service_of_provider',
  regexp: /service "([^\"]*)" of provider "([^\"]*)"/,
  transformer: ->(service_name, provider_name) do
    provider = Account.providers.find_by!(org_name: provider_name)
    provider.services.find_by!(name: service_name)
  end
)

# Finance

ParameterType(
  name: 'invoice',
  regexp: /^invoice "(.+?)"$/,
  transformer: ->(service_name, provider_name) { Invoice.find_by(id: id) or Invoice.find_by(friendly_id: id) or raise "Couldn't find Invoice with id #{id}" }
)

ParameterType(
  name: 'on/off',
  regexp: /^(on|off)$/,
  transformer: ->(state) { state == 'on' }
)

# Authentication Providers

OAUTH_PROVIDER_OPTIONS = {
  auth0: {
    site: "https://client.auth0.com"
  },
  keycloak: {
    site: "http://localhost:8080/auth/realms/3scale"
  }
}.freeze

ParameterType(
  name: 'authentication provider',
  regexp: /^authentication provider "([^\"]+)"$/,
  transformer: ->(authentication_provider_name) do
    authentication_provider = @provider.authentication_providers.find_by(name: authentication_provider_name)
    return authentication_provider if authentication_provider

    ap_underscored_name = authentication_provider_name.underscore
    options = OAUTH_PROVIDER_OPTIONS[ap_underscored_name.to_sym]
              .merge(
                {
                  system_name: "#{ap_underscored_name}_hex",
                  client_id: 'CLIENT_ID',
                  client_secret: 'CLIENT_SECRET',
                  kind: ap_underscored_name,
                  name: authentication_provider_name,
                  account_id: @provider.id,
                  identifier_key: 'id',
                  username_key: 'login',
                  trust_email: false
                }
              )

    authentication_provider_class = "AuthenticationProvider::#{authentication_provider_name}".constantize
    authentication_provider_class.create(options)
  end
)

# Boolean-like

ParameterType(
  name: 'enabled',
  regexp: /enabled|disabled/,
  transformer: ->(value) { value == 'enabled' }
)

ParameterType(
  name: 'activated',
  regexp: /activated|deactivated/,
  transformer: ->(value) { value == 'activated' }
)

ParameterType(
  name: 'default',
  regexp: /default| not default|/,
  transformer: ->(value) { value == 'default' }
)

ParameterType(
  name: 'published',
  regexp: /published|hidden/,
  transformer: ->(value) { value == 'published' }
)

ParameterType(
  name: 'public',
  regexp: /public|private/,
  transformer: ->(public) { public == 'public'}
)

ParameterType(
  name: 'live_state',
  regexp: /live|suspended/,
  transformer: ->(state) { state.titleize }
)

ParameterType(
  name: 'with',
  regexp: /with|without/,
  transformer: ->(value) { value == 'with' }
)

ParameterType(
  name: 'visible',
  regexp: /visible|hidden/,
  transformer: ->(value) { value == 'visible' }
)

ParameterType(
  name: 'is',
  regexp: /is|is not/,
  transformer: ->(value) { value == 'is' }
)

ParameterType(
  name: 'are',
  regexp: /are|are not/,
  transformer: ->(value) { value == 'are' }
)

ParameterType(
  name: 'see',
  regexp: /see|not see/,
  transformer: ->(value) { value == 'see' }
)

ParameterType(
  name: 'check',
  regexp: /check|uncheck/,
  transformer: ->(value) { value == 'check' }
)

ParameterType(
  name: 'should_see',
  regexp: /should see|should't see|should not see/,
  transformer: ->(value) { value == 'should see' }
)

# ParamterType(
#   name: 'should',
#   regexp: /should|should not|shouldn't/,
#   transformer: ->(value) { value == 'should' }
# )
