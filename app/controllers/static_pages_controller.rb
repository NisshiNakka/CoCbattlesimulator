class StaticPagesController < ApplicationController
  def top; end

  def roll_dice
    command = params[:command]
    game_type = params[:game_type] || "Cthulhu7th"

    if command.blank?
      flash.now[:alert] = "ダイスコマンドを入力してください"
      @result = { "error" => "コマンドが入力されていません" }
    else
      service = BcdiceApiService.new(game_type)
      @result = service.roll(command)

      Rails.logger.info "BCDice API Response: #{@result.inspect}"
    end

    render partial: "shared/dice_result", layout: false
  end
end
