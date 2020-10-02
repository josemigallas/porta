# frozen_string_literal: true

# TODO: replace this step with this one:
# Given "service discovery is {enabled}" do |enabled|
#   ThreeScale.config.service_discovery.stubs(enabled: enabled)
# end
Given(/^service discovery is (not )?enabled$/) do |disabled|
  ThreeScale.config.service_discovery.stubs(enabled: disabled.blank?)
end
