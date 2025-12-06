class BcdiceApiService
  include HTTParty
  base_uri "https://bcdice.onlinesession.app/v2"

  default_timeout 10

  def initialize(game_type)
    @game_type = game_type
  end

  def roll(command)
    Rails.logger.info "BCDice API Request: game_system=#{@game_system}, command=#{command}"
    
    # リトライロジック
    max_retries = 3
    retry_count = 0
    
    begin
      response = self.class.get(
        "/game_system/#{@game_system}/roll",
        query: { command: command },
        timeout: 10,  # タイムアウト: 10秒
        open_timeout: 5  # 接続タイムアウト: 5秒
      )
      
      Rails.logger.info "BCDice API Response Code: #{response.code}"
      
      if response.success?
        response.parsed_response
      else
        Rails.logger.error "BCDice API Error: code=#{response.code}, body=#{response.body}"
        { "error" => "API呼び出しに失敗しました（ステータスコード: #{response.code}）" }
      end
      
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      # タイムアウトエラー
      retry_count += 1
      if retry_count < max_retries
        Rails.logger.warn "BCDice API Timeout (retry #{retry_count}/#{max_retries}): #{e.message}"
        sleep(1)  # 1秒待機
        retry
      else
        Rails.logger.error "BCDice API Timeout (max retries exceeded): #{e.message}"
        { "error" => "APIへの接続がタイムアウトしました。時間をおいて再度お試しください。" }
      end
      
    rescue StandardError => e
      # その他のエラー
      Rails.logger.error "BCDice API Exception: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      { "error" => "API呼び出しに失敗しました: #{e.message}" }
    end
  end
end
