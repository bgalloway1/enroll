puts "::: Creating IVL 2015 benefit packages :::"

## 2015 Benefit Packages

hbx = HbxProfile.find_by_state_abbreviation("dc")

# Second lowest cost silver plan
slcsp_2015 = Plan.where(active_year: 2015).and(hios_id: "94506DC0390006-01").first
# slcsp_2015 = Plan.where(active_year: 2015).and(hios_id: "94506DC0390006-01").first

bc_period = hbx.benefit_sponsorship.benefit_coverage_periods.select { |bcp| bcp.start_on.year == 2015 }.first
bc_period.second_lowest_cost_silver_plan = slcsp_2015

ivl_health_plans_2015         = Plan.individual_health_by_active_year(2015).health_metal_nin_catastropic.entries.collect(&:_id)
ivl_dental_plans_2015         = Plan.individual_dental_by_active_year(2015).entries.collect(&:_id)
ivl_and_cat_health_plans_2015 = Plan.individual_health_by_active_year(2015).entries.collect(&:_id)


individual_health_benefit_package = BenefitPackage.new(
  title: "individual_health_benefits_2015",
  elected_premium_credit_strategy: "unassisted",
  benefit_ids:          ivl_health_plans_2015,
  benefit_eligibility_element_group: BenefitEligibilityElementGroup.new(
      market_places:        ["individual"],
      enrollment_periods:   ["open_enrollment", "special_enrollment"],
      family_relationships: BenefitEligibilityElementGroup::INDIVIDUAL_MARKET_RELATIONSHIP_CATEGORY_KINDS,
      benefit_categories:   ["health"],
      incarceration_status: ["unincarcerated"],
      age_range:            0..0,
      citizenship_status:   ["us_citizen", "naturalized_citizen", "alien_lawfully_present", "lawful_permanent_resident"],
      residency_status:     ["state_resident"],
      ethnicity:            ["any"]
    )
)

individual_dental_benefit_package = BenefitPackage.new(
  title: "individual_dental_benefits_2015",
  elected_premium_credit_strategy: "unassisted",
  benefit_ids:          ivl_dental_plans_2015,
  benefit_eligibility_element_group: BenefitEligibilityElementGroup.new(
      market_places:        ["individual"],
      enrollment_periods:   ["open_enrollment", "special_enrollment"],
      family_relationships: BenefitEligibilityElementGroup::INDIVIDUAL_MARKET_RELATIONSHIP_CATEGORY_KINDS,
      benefit_categories:   ["dental"],
      incarceration_status: ["unincarcerated"],
      age_range:            0..0,
      citizenship_status:   ["us_citizen", "naturalized_citizen", "alien_lawfully_present", "lawful_permanent_resident"],
      residency_status:     ["state_resident"],
      ethnicity:            ["any"]
    )
)

individual_catastrophic_health_benefit_package = BenefitPackage.new(
  title: "catastrophic_health_benefits_2015",
  elected_premium_credit_strategy: "unassisted",
  benefit_ids:          ivl_and_cat_health_plans_2015,
  benefit_eligibility_element_group: BenefitEligibilityElementGroup.new(
    market_places:        ["individual"],
    enrollment_periods:   ["open_enrollment", "special_enrollment"],
    family_relationships: BenefitEligibilityElementGroup::INDIVIDUAL_MARKET_RELATIONSHIP_CATEGORY_KINDS,
    benefit_categories:   ["health"],
    incarceration_status: ["unincarcerated"],
    age_range:            0..30,
    citizenship_status:   ["us_citizen", "naturalized_citizen", "alien_lawfully_present", "lawful_permanent_resident"],
    residency_status:     ["state_resident"],
    ethnicity:            ["any"]
  )
)

native_american_health_benefit_package = BenefitPackage.new(
  title: "native_american_health_benefits_2015",
  elected_premium_credit_strategy: "unassisted",
  benefit_ids:          ivl_health_plans_2015,
  benefit_eligibility_element_group: BenefitEligibilityElementGroup.new(
    market_places:        ["individual"],
    enrollment_periods:   ["open_enrollment", "special_enrollment"],
    family_relationships: BenefitEligibilityElementGroup::INDIVIDUAL_MARKET_RELATIONSHIP_CATEGORY_KINDS,
    benefit_categories:   ["health"],
    incarceration_status: ["unincarcerated"],
    age_range:            0..0,
    citizenship_status:   ["us_citizen", "naturalized_citizen", "alien_lawfully_present", "lawful_permanent_resident"],
    residency_status:     ["state_resident"],
    ethnicity:            ["indian_tribe_member"]
  )
)

native_american_dental_benefit_package = BenefitPackage.new(
  title: "native_american_dental_benefits_2015",
  elected_premium_credit_strategy: "unassisted",
  benefit_ids:          ivl_dental_plans_2015,
  benefit_eligibility_element_group: BenefitEligibilityElementGroup.new(
    market_places:        ["individual"],
    enrollment_periods:   ["any"],
    family_relationships: BenefitEligibilityElementGroup::INDIVIDUAL_MARKET_RELATIONSHIP_CATEGORY_KINDS,
    benefit_categories:   ["dental"],
    incarceration_status: ["unincarcerated"],
    age_range:            0..0,
    citizenship_status:   ["us_citizen", "naturalized_citizen", "alien_lawfully_present", "lawful_permanent_resident"],
    residency_status:     ["state_resident"],
    ethnicity:            ["indian_tribe_member"]
  )
)

bc_period.benefit_packages = [
    individual_health_benefit_package,
    individual_dental_benefit_package,
    individual_catastrophic_health_benefit_package,
    native_american_health_benefit_package,
    native_american_dental_benefit_package
  ]

bc_period.save!