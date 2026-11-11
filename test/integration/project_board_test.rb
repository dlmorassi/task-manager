require "test_helper"

class ProjectBoardTest < ActionDispatch::IntegrationTest
  setup do
    plan = Plan.create!(name: "Board plan", price: 0, user_limit: 100, project_limit: 100)
    organization = Organization.create!(name: "Studio", plan: plan)
    @user = organization.users.create!(first_name: "Ari", last_name: "Kim", email: "ari@example.com", password: "secure-password", role: :standard)
    @project = organization.projects.create!(name: "Website")
    @project.project_memberships.create!(user: @user)
    status = @project.statuses.create!(name: "To do", position: 0)
    @project.statuses.create!(name: "In progress", position: 1)
    @done = @project.statuses.create!(name: "Done", position: 2)
    @review = @project.statuses.create!(name: "In review", position: 3)
    @task = @project.tasks.create!(organization: organization, status: status, title: "Review homepage", story_points: 2.5)
  end

  test "project member can view the board and add a comment to a task" do
    post login_path, params: { identifier: @user.email, password: "secure-password" }

    get project_path(@project)
    assert_response :success
    assert_select "a.task-title", "Review homepage"
    assert_select ".status-order-button", 0

    get project_task_path(@project, @task)
    assert_response :success
    post project_task_comments_path(@project, @task), params: { comment: { body: "Looks good" } }
    assert_redirected_to project_task_path(@project, @task)
    assert_equal "Looks good", @task.comments.last.body
  end

  test "an organization admin can move a board status and the order persists" do
    admin = @user.organization.users.create!(
      first_name: "Morgan",
      last_name: "Admin",
      email: "admin@example.com",
      username: "morgan",
      password: "secure-password",
      role: :admin
    )
    @project.project_memberships.create!(user: admin)
    post login_path, params: { identifier: "MORGAN", password: "secure-password" }

    patch move_project_status_path(@project, @review), params: { direction: "left" }

    assert_redirected_to project_path(@project)
    assert_equal [ "To do", "In progress", "In review", "Done" ], @project.statuses.order(:position).pluck(:name)
    get project_path(@project)
    assert_equal [ "To do", "In progress", "In review", "Done" ], css_select(".board-column h2").map(&:text)
    assert_select ".status-order-button", 6
  end
end
