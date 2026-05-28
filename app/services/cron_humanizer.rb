class CronHumanizer
  Result = Data.define(:description, :error) do
    def success?
      error.blank?
    end
  end

  FIELD_RANGES = {
    minute: 0..59,
    hour: 0..23,
    day_of_month: 1..31,
    month: 1..12,
    day_of_week: 0..7
  }.freeze

  WEEKDAYS = {
    0 => "日曜日",
    1 => "月曜日",
    2 => "火曜日",
    3 => "水曜日",
    4 => "木曜日",
    5 => "金曜日",
    6 => "土曜日",
    7 => "日曜日"
  }.freeze

  def self.call(expression)
    new(expression).call
  end

  def initialize(expression)
    @expression = expression.to_s.squish
  end

  def call
    return Result.new(nil, "cron式を入力してください") if expression.blank?

    parts = expression.split
    return Result.new(nil, "5つのフィールドで入力してください") unless parts.size == 5

    fields = build_fields(parts)
    return Result.new(nil, fields[:error]) if fields[:error].present?

    Result.new(describe(fields), nil)
  end

  private

  attr_reader :expression

  def build_fields(parts)
    keys = FIELD_RANGES.keys
    parsed = keys.zip(parts).to_h do |key, value|
      [ key, parse_field(key, value) ]
    end

    error = parsed.values.find { |field| field[:error].present? }
    return { error: error[:error] } if error

    parsed
  end

  def parse_field(key, value)
    return { type: :any, value: value } if value == "*"

    if value.match?(/\A\*\/\d+\z/)
      step = value.delete_prefix("*/").to_i
      return { error: "#{label_for(key)}の間隔は1以上で入力してください" } if step < 1
      return { error: "#{label_for(key)}の間隔は#{FIELD_RANGES[key].last}以下で入力してください" } if step > FIELD_RANGES[key].last

      return { type: :step, step: step }
    end

    if value.match?(/\A\d+\z/)
      number = value.to_i
      return { error: "#{label_for(key)}は#{FIELD_RANGES[key].first}から#{FIELD_RANGES[key].last}で入力してください" } unless FIELD_RANGES[key].cover?(number)

      return { type: :number, number: number }
    end

    if value.match?(/\A\d+-\d+\z/)
      start_value, end_value = value.split("-").map(&:to_i)
      valid_range = FIELD_RANGES[key].cover?(start_value) && FIELD_RANGES[key].cover?(end_value) && start_value <= end_value
      return { error: "#{label_for(key)}の範囲が正しくありません" } unless valid_range

      return { type: :range, start_value: start_value, end_value: end_value }
    end

    { error: "#{label_for(key)}に未対応の値があります" }
  end

  def describe(fields)
    minute = fields[:minute]
    hour = fields[:hour]
    day_of_month = fields[:day_of_month]
    month = fields[:month]
    day_of_week = fields[:day_of_week]

    return "毎分" if all_any?(fields)
    return "#{minute[:step]}分ごと" if minute[:type] == :step && [ hour, day_of_month, month, day_of_week ].all? { |field| field[:type] == :any }

    schedule_parts = []
    schedule_parts << describe_month(month) unless month[:type] == :any
    schedule_parts << describe_day_of_month(day_of_month) unless day_of_month[:type] == :any
    schedule_parts << describe_day_of_week(day_of_week) unless day_of_week[:type] == :any

    time_description = describe_time(hour, minute)
    return time_description if schedule_parts.empty? && hour[:type] == :step
    return time_description if schedule_parts.empty? && time_description.start_with?("毎")
    return "毎日#{time_description}" if schedule_parts.empty?

    "#{schedule_parts.join('、')}の#{time_description}"
  end

  def all_any?(fields)
    fields.values.all? { |field| field[:type] == :any }
  end

  def describe_time(hour, minute)
    return format("%<hour>d:%<minute>02d", hour: hour[:number], minute: minute[:number]) if hour[:type] == :number && minute[:type] == :number
    return describe_minute_for_any_hour(minute) if hour[:type] == :any

    "#{describe_hour(hour)}の#{describe_minute(minute)}"
  end

  def describe_minute_for_any_hour(field)
    return "毎分" if field[:type] == :any
    return "毎時#{field[:number]}分" if field[:type] == :number
    return describe_minute(field) if field[:type] == :step

    "毎時#{describe_minute(field)}" if field[:type] == :range
  end

  def describe_hour(field)
    return "#{field[:number]}時" if field[:type] == :number
    return "#{field[:start_value]}時から#{field[:end_value]}時" if field[:type] == :range

    "#{field[:step]}時間ごと"
  end

  def describe_minute(field)
    return "毎分" if field[:type] == :any
    return "#{field[:number]}分" if field[:type] == :number
    return "#{field[:start_value]}分から#{field[:end_value]}分" if field[:type] == :range

    "#{field[:step]}分ごと"
  end

  def describe_month(field)
    return "#{field[:number]}月" if field[:type] == :number
    return "#{field[:start_value]}月から#{field[:end_value]}月" if field[:type] == :range

    "#{field[:step]}か月ごと"
  end

  def describe_day_of_month(field)
    return "毎月#{field[:number]}日" if field[:type] == :number
    return "毎月#{field[:start_value]}日から#{field[:end_value]}日" if field[:type] == :range

    "#{field[:step]}日ごと"
  end

  def describe_day_of_week(field)
    return "毎週#{WEEKDAYS.fetch(field[:number])}" if field[:type] == :number
    return "#{WEEKDAYS.fetch(field[:start_value])}から#{WEEKDAYS.fetch(field[:end_value])}" if field[:type] == :range

    "#{field[:step]}日おきの曜日"
  end

  def label_for(key)
    {
      minute: "分",
      hour: "時",
      day_of_month: "日",
      month: "月",
      day_of_week: "曜日"
    }.fetch(key)
  end
end
