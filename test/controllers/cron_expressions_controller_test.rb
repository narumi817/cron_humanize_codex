require "test_helper"

class CronExpressionsControllerTest < ActionDispatch::IntegrationTest
  test "shows form" do
    get root_path

    assert_response :success
    assert_select "h1", "cron humanizer"
  end

  test "shows humanized expression" do
    get root_path, params: { expression: "0 9 * * *" }

    assert_response :success
    assert_select ".result-success strong", "毎日9:00"
  end

  test "shows validation error" do
    get root_path, params: { expression: "60 9 * * *" }

    assert_response :success
    assert_select ".result-error strong", "分は0から59で入力してください"
  end
end
