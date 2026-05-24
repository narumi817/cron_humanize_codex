class CronExpressionsController < ApplicationController
  def new
    @expression = params[:expression].to_s
    return if @expression.blank?

    @result = CronHumanizer.call(@expression)
  end
end
