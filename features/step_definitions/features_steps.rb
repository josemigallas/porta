# frozen_string_literal: true

Given "a feature {string} of {provider}" do |feature_name, provider|
  provider.default_service.features.create!(name: feature_name)
end

Given "feature {string} is {visible}" do |feature_name, visible|
  feature = Feature.find_by!(name: feature_name)
  feature.visible = visible
  feature.save!
end

Given "feature {string} is {enabled} for plan {string}" do |feature_name, enabled, plan|
  #FIXME: if the feature does not exist this blows!
  feature = plan.service.features.find_by!(name: feature_name)

  if enabled
    plan.features << feature
  else
    plan.features.delete(feature)
  end
end

When /^I press the (enable|disable) button for feature "([^"]*)"$/ do |state, name|
  button = find(%(table#features td:contains("#{name}") ~ td form input[type=image]))
  button.click
end

When /^I (follow|press) "([^"]*)" for (feature "[^"]*")$/ do |action, label, feature|
  step %(I #{action} "#{label}" within "##{dom_id(feature)}")
end

Then "feature {string} should be {enabled} for {plan}" do |name, enabled, plan|
  assertion = enabled ? :assert_not_nil : :assert_nil

  send(assertion, plan.features.find_by!(name: name))
end

Then /^I should see (enabled|disabled) feature "([^"]*)"$/ do |state, name|
  assert has_css?(%(table#features tr.#{state} td:contains("#{name}")))
end

Then /^I should see feature "([^"]*)"$/ do |name|
  assert has_css?(%(table#features td:contains("#{name}")))
end

Then /^I should not see feature "([^"]*)"$/ do |name|
  assert has_no_css?(%(table#features td:contains("#{name}")))
end


Then "{provider} should not have feature {string}" do |provider, name|
  assert_nil provider.default_service.features.find_by!(name: name)
end
