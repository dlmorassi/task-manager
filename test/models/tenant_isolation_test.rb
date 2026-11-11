require "test_helper"

class TenantIsolationTest < ActiveSupport::TestCase
  setup do
    @plan = Plan.create!(name: "Test", price: 0, user_limit: 100, project_limit: 100)
    @organization = Organization.create!(name: "North", plan: @plan)
    @other_organization = Organization.create!(name: "South", plan: @plan)
    @user = create_user(@organization, "member@example.com")
    @other_user = create_user(@other_organization, "other@example.com")
    @project = Project.create!(name: "Launch", organization: @organization)
    @status = Status.create!(name: "To do", project: @project, position: 0)
    @task = Task.create!(title: "Write brief", organization: @organization, project: @project, status: @status)
  end

  test "project membership rejects users from another organization" do
    membership = ProjectMembership.new(project: @project, user: @other_user)

    assert_not membership.valid?
    assert_includes membership.errors[:user], "must belong to the project's organization"
  end

  test "task status must belong to its project" do
    other_status = Status.create!(name: "Doing", project: Project.create!(name: "Other", organization: @organization), position: 0)
    task = Task.new(title: "Misrouted", organization: @organization, project: @project, status: other_status)

    assert_not task.valid?
    assert_includes task.errors[:status], "must belong to the task's project"
  end

  test "task assignees and commenters must belong to the same organization" do
    assignment = TaskAssignment.new(task: @task, user: @other_user)
    comment = Comment.new(task: @task, user: @other_user, body: "Cross-tenant comment")

    assert_not assignment.valid?
    assert_not comment.valid?
  end

  test "story points enforce the supported range" do
    @task.story_points = 0
    assert_not @task.valid?

    @task.story_points = 1_000_000
    assert_not @task.valid?
  end

  private

  def create_user(organization, email)
    organization.users.create!(
      first_name: "Taylor",
      last_name: "Lee",
      email: email,
      password: "secure-password",
      role: :standard
    )
  end
end
