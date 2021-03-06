### UTILITY METHODS ###
def create_user
  @user = FactoryGirl.create(:user)
end

def find_user
  @user = FactoryGirl.create(:user)
end

def delete_user
  @user.destroy unless @user.nil?
end

def sign_up
  delete_user
  visit '/users/auth/github'
  find_user
end

def sign_in
  visit '/users/auth/github'
  find_user
end

### GIVEN ###
Given /^we have (\d+) users$/  do |number|
  FactoryGirl.create_list(:user, number.to_i - 1)
end

Given /^we have user "(.*?)" with name "(.*?)"$/ do |username, name|
  FactoryGirl.create(:user, :username => username, :name => name)
end

Given /^I am not logged in$/ do
  visit '/sign_out'
end

Given /^I am logged in$/ do
  step "I am logged in as \"user\""
end

Given /^I am logged in as "(.*?)"$/ do |role|
  # First user is always admin
  FactoryGirl.create(:user) if role != "admin"
  
  visit '/users/auth/github'
  @user = User.order("created_at DESC").first
  @user.update_attributes(:role => role)
end

Given /^I exist as a user$/ do
  create_user
end

Given /^I do not exist as a user$/ do
  delete_user
end

### WHEN ###
When /^I sign in$/ do
  sign_in
end

When /^I sign out$/ do
  visit '/sign_out'
end

When /^I return to the site$/ do
  visit '/'
end

When /^I go to my account page$/ do
  visit '/users/me'
end

When /^I click on user "(.*?)"$/ do |username|
  click_link "link_#{username}"
  page.driver.render("tmp/capybara/#{username}.png")
end

When /^I click on the Delete button for user "(.*?)" and confirm$/ do |username|
  within("#user_#{username}") do
    click_link "#{username}-delete"
  end
end

When /^I click on the "(.*?)" submenu of button Edit for user "(.*?)"$/ do |menu_item, username|
  role = menu_item.split.last.downcase
  within("#user_#{username}") do
    click_link "#{username}-update"
    click_link "#{username}-update-#{role}"
  end
end

### THEN ###
Then /^I should see (\d+) user[s]?$/ do |number|
  page.should have_css('div.accordion-group', :visible => true, :count => number.to_i)
end

Then /^I should see user "(.*?)"$/ do |username|
  page.should have_css("a#link_#{username}")
end

Then /^I should not see user "(.*?)"$/ do |username|
  page.should_not have_css("a#link_#{username}")
end

Then /^I should be signed in$/ do
  page.should have_link("Sign Out", :href => "/sign_out")
  page.should_not have_link("Sign in with Github", :href => "/users/auth/github")
end

Then /^I should be signed out$/ do
  page.should have_link("Sign in with Github", :href => "/users/auth/github")
  page.should_not have_link("Sign Out", :href => "/sign_out")
end

Then /^I should reach the Sign In page$/ do
  page.should have_link("Sign in with Github", :href => "/users/auth/github")
end

Then /^I should not see the "(.*?)" button$/ do |title|
  page.should_not have_link(title)
end

Then(/^I should see the API key$/) do
  page.should have_css('dt', :text => "API Key")
end

Then /^I should see the "(.*?)" role for user "(.*?)"$/ do |role, username|
  within("#user_#{username}") do
    page.should have_content role
  end
end