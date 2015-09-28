@watir @screenshots @no-database-cleaner 
Feature: Insured Plan Shopping on Individual market
  Scenario: New insured user purchases on individual market
    Given Individual has not signed up as an HBX user
      When I use unique values
      When I visit the Insured portal
      Then Individual creates HBX account
      Then I should see a successful sign up message
      When user goes to register as an individual
      When user clicks on continue button
      Then user should see button to continue as an individual
      Then Individual should click on Individual market for plan shopping
      Then Individual should see a form to enter personal information
      When Individual clicks on Save and Exit
      Then Individual resumes enrollment
      Then Individual fixes a VLP error message
      When Individual clicks on continue button
      Then Individual should see identity verification page and clicks on submit
      Then Individual should see the dependents form
      And Individual clicks on add member button
      And Individual again clicks on add member button
      And I click on continue button on household info form
      And I click on continue button on group selection page
      And I select a plan on plan shopping page
      And I click on purchase button on confirmation page
      And I click on continue button to go to the individual home page
      And I should see the individual home page
      When I click the "I've married" in qle carousel
      And I select a future qle date
      Then I should see not qualify message
      When I click the "I've married" in qle carousel
      And I select a past qle date
      Then I should see confirmation and continue
      When I click on continue button on household info form
      And I click on "shop for new plan" button on household info page
      And I select a plan on plan shopping page
      And I click on purchase button on confirmation page
      When I click on continue on qle confirmation page
      And I should see the individual home page
      And I click to see my Secure Purchase Confirmation
      Then Individual logs out

      When I visit the Insured portal
      Then Second user creates an individual account
      Then Second user goes to register as an individual
      Then user clicks on continue button
      Then click continue again
      Then Second user should see a form to enter personal information
      Then user clicks on continue button
      Then Second user sees the Verify Identity Consent page
      Then Second user asks for help
      And Second user logs out
      When CSR accesses the HBX portal
      Then CSR should see the Agent Portal
      Then CSR opens the most recent Please Contact Message
      Then CSR clicks on Resume Application via phone
      Then CSR should see identity verification page and clicks on submit
      Then CSR should see the dependents form
      And I click on the header link to return to CSR page
      Then CSR should see the Agent Portal
      Then CSR clicks on New Consumer Paper Application
      Then CSR starts a new enrollment


