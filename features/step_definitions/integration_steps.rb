require 'watir'
require 'pry'
# load Rails.root + "db/seeds.rb"

module WatirScreenshots
  def screenshot(name = nil)
    if @take_screens
      shot_count = @screen_count.to_s.rjust(3, "0")
      f_name = name.nil? ? shot_count : "#{shot_count}_#{name}"
      @browser.screenshot.save("tmp/#{f_name}.png")
      @screen_count = @screen_count + 1
    end
  end
end

Before "@watir" do
  extend WatirScreenshots
  @browser = Watir::Browser.new :chrome, switches: ["--test-type"]
  @browser.window.resize_to(1440, 900)
  @screen_count = 0
  @take_screens = ENV.has_key?("DISABLE_WATIR_SCREENSHOTS") ? false : true
  @keep_browser_open = ENV.has_key?("KEEP_WATIR_BROWSERS_OPEN") ? true : false
end

After "@watir" do
  @browser.close unless @keep_browser_open
  @take_screens = false if @take_screens
end

Given(/^I do not exist as a user$/) do
end

Given(/^I have an existing employee record$/) do
end

Given(/^I have an existing person record$/) do
end

Given(/^I am employed by an employer with no published plan year$/) do
end

When(/^I go to the employee account creation page$/) do
  @browser.goto("http://localhost:3000/")
  @browser.a(text: "Employee Portal").wait_until_present
  screenshot("start")
  @browser.a(text: "Employee Portal").click
  @browser.a(text: "Create account").wait_until_present
  screenshot("employee_portal")
  @browser.a(text: "Create account").click
end

When(/^I enter my new account information$/) do
  @browser.text_field(name: "user[password_confirmation]").wait_until_present
  screenshot("create_account")
  @email = "swhite#{rand(100)}@example.com"
  @password = "12345678"
  @browser.text_field(name: "user[email]").set(@email)
  @browser.text_field(name: "user[password]").set(@password)
  @browser.text_field(name: "user[password_confirmation]").set(@password)
  @browser.input(value: "Create account").click
end

Then(/^I should be logged in$/) do
  @browser.a(href: /consumer.employee.search/).wait_until_present
  screenshot("logged_in_welcome")
  expect(@browser.a(href: /consumer.employee.search/).visible?).to be_truthy
end

When (/^(.*) logs? out$/) do |someone|
  @browser.element(class: /interaction-click-control-logout/).click
  @browser.element(class: /interaction-click-control-logout/).wait_while_present
end

Then(/^I should see the hbx home page$/) do
  @browser.element(class: /interaction-click-control-employee-portal/).wait_until_present
end

When(/^I go to register as an employee$/) do
  @browser.element(class: /interaction-click-control-continue/).wait_until_present
  @browser.element(class: /interaction-click-control-continue/).click
end

Then(/^I should see the employee search page$/) do
  @browser.text_field(class: /interaction-field-control-person-first-name/).wait_until_present
  screenshot("employer_search")
  expect(@browser.text_field(class: /interaction-field-control-person-first-name/).visible?).to be_truthy
end

def people
  {
    "Soren White" => {
      first_name: "Soren",
      last_name: "White",
      dob: "08/13/1979",
      ssn: "670991234",
    },
    "Patrick Doe" => {
      first_name: "Patrick",
      last_name: "Doe",
      dob: "01/01/1980",
      ssn: "786120965",
    }
  }
end

When(/^I enter the identifying info of (.*)$/) do |named_person|
  person = people[named_person]
  @browser.text_field(class: /interaction-field-control-person-first-name/).set(person[:first_name])
  @browser.text_field(name: "person[last_name]").set(person[:last_name])
  @browser.text_field(name: "jq_datepicker_ignore_person[dob]").set(person[:dob])
  @browser.label(:text=> /FIRST NAME/).click
  @browser.text_field(name: "person[ssn]").set(person[:ssn])
  screenshot("information_entered")
  @browser.element(class: /interaction-click-control-continue/).wait_until_present
  @browser.element(class: /interaction-click-control-continue/).click
end
# # TODO: needs to be merged
# When(/^I enter the identifying information of my existing person$/) do
#   @browser.text_field(name: "person[first_name]").set("Patrick")
#   @browser.text_field(name: "person[last_name]").set("Doe")
#   @browser.text_field(name: "jq_datepicker_ignore_person[dob]").set("01/01/1980")
#   @browser.label(:text=> /FIRST NAME/).click
#   @browser.text_field(name: "person[ssn]").set("786120965")
#   screenshot("information_entered")
#   @browser.element(class: /interaction-click-control-continue/).wait_until_present
#   @browser.element(class: /interaction-click-control-continue/).click
#   @browser.element(class: /interaction-click-control-continue/).wait_while_present
# end

Then(/^I should not see the matched employee record form$/) do
  @browser.element(class: /fa-exclamation-triangle/).wait_until_present
  expect(@browser.element(class: /interaction-click-control-this-is-my-employer/).exists?).to be_falsey
end

Then(/^I should see the matched employee record form$/) do
  @browser.dd(text: /Acme Inc\./).wait_until_present
  screenshot("employer_search_results")
  expect(@browser.dd(text: /Acme Inc\./).visible?).to be_truthy
end
# TODO: needs to be merged
Then(/^I should see the matching employee record form$/) do
  @browser.element(text: /Turner Agency/).wait_until_present
  screenshot("employer_search_results")
  expect(@browser.element(text: /Turner Agency/).visible?).to be_truthy
end

When(/^I accept the matched employer$/) do
  @browser.input(value: /This is my employer/).click
  @browser.input(name: "person[emails_attributes][0][address]").wait_until_present
  screenshot("update_personal_info")
end

When(/^I complete the matched employee form$/) do
  @browser.text_field(name: "person[phones_attributes][0][full_phone_number]").set("2025551234")
  @browser.text_field(name: "person[emails_attributes][1][address]").click
  screenshot("personal_info_complete")
  @browser.button(id: /btn-continue/).wait_until_present
  @browser.button(id: /btn-continue/).click
end
# TODO: needs to be merged
When(/^I complete the matching employee form$/) do
  @browser.text_field(name: "person[addresses_attributes][0][address_1]").set("84 I st")
  @browser.text_field(name: "person[addresses_attributes][0][address_2]").set("Suite 201")
  @browser.text_field(name: "person[addresses_attributes][0][city]").set("Herndon")
  @browser.text_field(name: "person[addresses_attributes][0][state]").set("VA")
  @browser.text_field(name: "person[addresses_attributes][0][zip]").set("20171")

  @browser.text_field(name: "person[phones_attributes][0][full_phone_number]").set("2025551234")
  @browser.text_field(name: "person[emails_attributes][1][address]").click
  screenshot("personal_info_complete")
  # @browser.button(class: /interaction-click-control-continue/).click  # TODO cant find interaction element
  @browser.button(id: /btn-continue/).wait_until_present
  @browser.button(id: /btn-continue/).click
end


Then(/^I should see the dependents page$/) do
  @browser.a(text: /Add Member/).wait_until_present
  screenshot("dependents_page")
  expect(@browser.a(text: /Add Member/).visible?).to be_truthy
end

When(/^I click edit on baby Soren$/) do
  @browser.span(text: "07/03/2014").as(xpath: "./preceding::a[contains(@href, 'edit')]").last.click
end

Then(/^I should see the edit dependent form$/) do
  @browser.button(:text => /Confirm Member/).wait_until_present
end

When(/^I click delete on baby Soren$/) do
  @browser.form(id: 'edit_dependent').a().click
  @browser.button(text: /Confirm Member/).wait_while_present
end

Then(/^I should see (.*) dependents$/) do |n|
  n = n.to_i
  expect(@browser.li(class: "dependent_list", index: n)).not_to exist
  expect(@browser.li(class: "dependent_list", index: n - 1)).to exist
end

When(/^I click Add Member$/) do
  @browser.a(text: /Add Member/).click
  @browser.button(text: /Confirm Member/).wait_until_present
end

Then(/^I should see the new dependent form$/) do
  expect(@browser.button(text: /Confirm Member/).visible?).to be_truthy
end

When(/^I enter the dependent info of Sorens daughter$/) do
  @browser.text_field(name: 'dependent[first_name]').set('Cynthia')
  @browser.text_field(name: 'dependent[last_name]').set('White')
  @browser.text_field(name: 'jq_datepicker_ignore_dependent[dob]').set('01/15/2011')
  input_field = @browser.div(class: /selectric-wrapper/)
  input_field.click
  input_field.li(text: /Child/).click
  @browser.radio(id: /radio_female/).fire_event("onclick")
end

When(/^I click confirm member$/) do
  @browser.button(text: /Confirm Member/).click
  @browser.button(text: /Confirm Member/).wait_while_present
end

When(/^I click continue on the dependents page$/) do
  @browser.button(class: /interaction-click-control-continue/).click
end

Then(/^I should see the group selection page$/) do
  @browser.form(action: /group_selection\/create/).wait_until_present
  screenshot("group_selection")
end

When(/^I click continue on the group selection page$/) do
  @browser.element(class: /interaction-click-control-continue/, id: /btn-continue/).wait_until_present
  @browser.element(class: /interaction-click-control-continue/, id: /btn-continue/).click
end

Then(/^I should see the plan shopping welcome page$/) do
  @browser.element(text: /Filter Results/i).wait_until_present
  # @browser.h3(text: /Select a Plan/).wait_until_present
  screenshot("plan_shopping_welcome")
  expect(@browser.element(text: /Choose a healthcare plan/i).visible?).to be_truthy
  # expect(@browser.h3(text: /Select a Plan/).visible?).to be_truthy
end

When(/^I click continue on the plan shopping welcome page$/) do
  @browser.a(text: "Continue").click
end

Then(/^I should see the list of plans$/) do
  @browser.a(text: /Select/).wait_until_present
  screenshot("plan_shopping")
end

When(/^I select a plan on the plan shopping page$/) do
  @browser.execute_script(
    'arguments[0].scrollIntoView();',
    @browser.element(:text => /Choose a healthcare plan/)
  )
  @browser.a(text: /Select/).click
end

Then(/^I should see the coverage summary page$/) do
  @browser.element(id: /btn-continue/).wait_until_present
  screenshot("summary_page")
  expect(@browser.element(text: /Confirm Your Plan Selection/i).visible?).to be_truthy
end

When(/^I confirm on the coverage summary page$/) do
  @browser.element(class: /interaction-click-control-purchase/).click
end

Then(/^I should see the "my account" page$/) do
  @browser.element(text: /Your Life Events/i).wait_until_present
  screenshot("my_account_page")
  expect(@browser.element(text: /Your Life Events/i).visible?).to be_truthy
end

When(/^My employer publishes a plan year$/) do
  @browser.a(text: /Employer Portal/).wait_until_present
  @browser.a(text: /Employer Portal/).click
  @browser.element(class: /interaction-field-control-user-email/).wait_until_present
  @browser.text_field(class: /interaction-field-control-user-email/).set(@email)
  @browser.text_field(class: /interaction-field-control-user-password/).set(@password)
  @browser.element(class: /interaction-click-control-sign-in/).click
  @browser.text_field(name: "organization[first_name]").wait_until_present
  @browser.text_field(name: "organization[first_name]").set("Soren")
  @browser.text_field(name: "organization[last_name]").set("White")
  @browser.text_field(name: "jq_datepicker_ignore_organization[dob]").set("08/13/1979")
  @browser.text_field(name: "organization[first_name]").click

  @browser.text_field(name: "organization[legal_name]").set("Acme Inc.")
  @browser.text_field(name: "organization[dba]").set("Acme Inc.")
  @browser.text_field(name: "organization[fein]").set("764141112")
  input_field = @browser.divs(class: "selectric-interaction-choice-control-organization-entity-kind").first
  input_field.click
  input_field.li(text: /C Corporation/).click
  @browser.text_field(name: "organization[office_locations_attributes][0][address_attributes][address_1]").set("830 I St NE")
  @browser.text_field(name: "organization[office_locations_attributes][0][address_attributes][city]").set("Washington")
  @browser.text_field(name: "organization[office_locations_attributes][0][address_attributes][state]").set("DC")
  @browser.text_field(name: "organization[office_locations_attributes][0][address_attributes][zip]").set("20002")
  @browser.text_field(name: "organization[office_locations_attributes][0][phone_attributes][area_code]").set("202")
  @browser.text_field(name: "organization[office_locations_attributes][0][phone_attributes][number]").set("5551212")
  @browser.button(class: "interaction-click-control-create-employer").click
  @browser.element(class: /interaction-click-control-benefits/).wait_until_present
  @browser.element(class: /interaction-click-control-benefits/).click
  @browser.element(class: /interaction-click-control-publish-plan-year/).wait_until_present
  @browser.element(class: /interaction-click-control-publish-plan-year/).click
end

When(/^I log in to the employee account page$/) do
  @browser.a(text: /Employee Portal/).wait_until_present
  @browser.a(text: /Employee Portal/).click
  @browser.element(class: /interaction-field-control-user-email/).wait_until_present
  @browser.text_field(class: /interaction-field-control-user-email/).set(@email)
  @browser.text_field(class: /interaction-field-control-user-password/).set(@password)
  @browser.element(class: /interaction-click-control-sign-in/).click
end
