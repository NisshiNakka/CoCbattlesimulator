class BcdiceApiService
  include HTTParty
  base_uri "https://bcdice.onlinesession.app/v2"

  default_timeout 10

  headers(
    "User-Agent" => "Mozilla/5.0 (compatible; CoC Battle Simulator/1.0; +https://cocbattlesimulator.onrender.com)",
    "Accept" => "application/json",
    "Accept-Language" => "ja,en;q=0.9"
  )

  def initialize(game_type)
    @game_type = game_type
  end

  def roll(command)
    Rails.logger.info "BCDice API Request: game_type=#{@game_type}, command=#{command}"

    max_retries = 3
    retry_count = 0

    begin
      response = self.class.get(
        "/game_system/#{@game_type}/roll",
        query: { command: command },
        timeout: 10,
        open_timeout: 5,
        headers: {
          "User-Agent" => "Mozilla/5.0 (compatible; CoC Battle Simulator/1.0; +https://cocbattlesimulator.onrender.com)",
          "Accept" => "application/json",
          "Accept-Language" => "ja,en;q=0.9"
        }
      )

      Rails.logger.info "BCDice API Response Code: #{response.code}"

      if response.success?
        response.parsed_response
      else
        Rails.logger.error "BCDice API Error: code=#{response.code}"
        { "error" => "API呼び出しに失敗しました（ステータスコード: #{response.code}）" }
      end

    rescue Net::OpenTimeout, Net::ReadTimeout => e
      retry_count += 1
      if retry_count < max_retries
        Rails.logger.warn "BCDice API Timeout (retry #{retry_count}/#{max_retries})"
        sleep(1)
        retry
      else
        Rails.logger.error "BCDice API Timeout (max retries exceeded)"
        { "error" => "APIへの接続がタイムアウトしました" }
      end

    rescue StandardError => e
      Rails.logger.error "BCDice API Exception: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      { "error" => "API呼び出しに失敗しました: #{e.message}" }
    end
  end
end
