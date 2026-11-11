require "test_helper"

class RegistrationTest < ActionDispatch::IntegrationTest
  setup do
    Plan.find_or_create_by!(name: "Free") do |plan|
      plan.price = 0
      plan.user_limit = 99_999
      plan.project_limit = 99_999
    end
  end

  test "registration creates an organization admin and signs them in" do
    assert_difference [ "Organization.count", "User.count" ], 1 do
      post sign_up_path, params: {
        organization: { name: "Acme Studio", segment: "Design", description: "Product team" },
        user: {
          first_name: "Sam",
          last_name: "Rivera",
          email: "sam@example.com",
          username: "samr",
          password: "secure-password",
          password_confirmation: "secure-password"
        }
      }
    end

    user = User.find_by!(email: "sam@example.com")
    assert_equal "admin", user.role
    assert_equal "Acme Studio", user.organization.name
    assert_equal user.id, session[:user_id]
    assert_redirected_to projects_path
  end
end
