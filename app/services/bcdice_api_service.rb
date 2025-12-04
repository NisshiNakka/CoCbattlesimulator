class BcdiceApiService
  include HTTParty
  base_uri "https://bcdice.onlinesession.app/v2"

  def initialize(game_type)
    @game_type = game_type
  end

  def roll(command)
    response = self.class.get(
      "/game_system/#{@game_type}/roll",
      query: { command: command }
    )

    handle_response(response)
  end

  private

  def handle_response(response)
    if response.success?
      response.parsed_response
    else
      { error: "API呼び出しに失敗しました" }
    end
  end
end
