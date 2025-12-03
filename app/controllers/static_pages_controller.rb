class StaticPagesController < ApplicationController
  def top
    if params[:command].present?
      service = BcdiceApiService.new(params[:game_system] || 'Cthulhu7th')
      @result = service.roll(params[:command])
    end
  end
  
  def roll_dice
    command = params[:command]
    game_system = params[:game_system] || 'Cthulhu7th'
    
    if command.blank?
      redirect_to root_path, alert: "ダイスコマンドを入力してください"
      return
    end
    
    redirect_to root_path(command: command, game_system: game_system)
  end
end
