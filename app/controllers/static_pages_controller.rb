class StaticPagesController < ApplicationController
  def top; end

  def roll_dice
    command = params[:command]
    game_system = params[:game_system] || "Cthulhu7th"

    if command.blank?
      flash.now[:alert] = "ダイスコマンドを入力してください"
      @result = { "error" => "コマンドが入力されていません" }
    else
      service = BcdiceApiService.new(game_system)
      @result = service.roll(command)

      Rails.logger.info "BCDice API Response: #{@result.inspect}"
    end

    render partial: "shared/dice_result", layout: false
  end
end
