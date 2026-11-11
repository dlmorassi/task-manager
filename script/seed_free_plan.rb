Plan.find_or_create_by!(name: "Free") do |plan|
  plan.price = 0
  plan.user_limit = 99_999
  plan.project_limit = 99_999
  plan.discount_active = false
  plan.discount_percentage = 0
end

puts "Free plan is ready."
