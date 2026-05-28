require "test_helper"

class CronHumanizerTest < ActiveSupport::TestCase
  test "describes every minute" do
    result = CronHumanizer.call("* * * * *")

    assert_predicate result, :success?
    assert_equal "毎分", result.description
  end

  test "describes daily schedule" do
    result = CronHumanizer.call("0 9 * * *")

    assert_predicate result, :success?
    assert_equal "毎日9:00", result.description
  end

  test "describes weekday schedule" do
    result = CronHumanizer.call("30 9 * * 1-5")

    assert_predicate result, :success?
    assert_equal "月曜日から金曜日の9:30", result.description
  end

  test "describes minute step" do
    result = CronHumanizer.call("*/15 * * * *")

    assert_predicate result, :success?
    assert_equal "15分ごと", result.description
  end

  test "describes hour step" do
    result = CronHumanizer.call("0 */2 * * *")

    assert_predicate result, :success?
    assert_equal "2時間ごとの0分", result.description
  end

  test "describes hour range" do
    result = CronHumanizer.call("0 9-17 * * *")

    assert_predicate result, :success?
    assert_equal "毎日9時から17時の0分", result.description
  end

  test "describes minute range" do
    result = CronHumanizer.call("1-5 * * * *")

    assert_predicate result, :success?
    assert_equal "毎時1分から5分", result.description
  end

  test "describes step and range combination" do
    result = CronHumanizer.call("*/15 9-17 * * 1-5")

    assert_predicate result, :success?
    assert_equal "月曜日から金曜日の9時から17時の15分ごと", result.description
  end

  test "rejects missing expression" do
    result = CronHumanizer.call("")

    assert_not result.success?
    assert_equal "cron式を入力してください", result.error
  end

  test "rejects unsupported field count" do
    result = CronHumanizer.call("0 9 * *")

    assert_not result.success?
    assert_equal "5つのフィールドで入力してください", result.error
  end

  test "rejects out of range value" do
    result = CronHumanizer.call("60 9 * * *")

    assert_not result.success?
    assert_equal "分は0から59で入力してください", result.error
  end

  test "rejects minute step greater than field maximum" do
    result = CronHumanizer.call("*/100 * * * *")

    assert_not result.success?
    assert_equal "分の間隔は59以下で入力してください", result.error
  end

  test "rejects hour step greater than field maximum" do
    result = CronHumanizer.call("0 */24 * * *")

    assert_not result.success?
    assert_equal "時の間隔は23以下で入力してください", result.error
  end

  test "rejects day of month step greater than field maximum" do
    result = CronHumanizer.call("0 0 */32 * *")

    assert_not result.success?
    assert_equal "日の間隔は31以下で入力してください", result.error
  end

  test "rejects month step greater than field maximum" do
    result = CronHumanizer.call("0 0 * */13 *")

    assert_not result.success?
    assert_equal "月の間隔は12以下で入力してください", result.error
  end

  test "rejects day of week step greater than field maximum" do
    result = CronHumanizer.call("0 0 * * */8")

    assert_not result.success?
    assert_equal "曜日の間隔は7以下で入力してください", result.error
  end
end
