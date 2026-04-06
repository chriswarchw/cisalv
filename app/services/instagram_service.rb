class InstagramService
  INSTAGRAM_API_URL = "https://graph.instagram.com"

  def initialize(access_token)
    @access_token = access_token
  end

  def media_fields
    "id,caption,media_type,media_url,thumbnail_url,permalink,timestamp,like_count,comments_count"
  end

  def fetch_media(limit: 12)
    response = HTTParty.get(
      "#{INSTAGRAM_API_URL}/me/media",
      query: {
        fields: media_fields,
        access_token: @access_token,
        limit: limit
      }
    )

    return [] unless response.success?

    data = response.parsed_response["data"] || []

    data.map do |post|
      {
        id: post["id"],
        caption: post["caption"],
        media_type: post["media_type"],
        media_url: post["media_type"] == "VIDEO" ? post["thumbnail_url"] : post["media_url"],
        permalink: post["permalink"],
        timestamp: post["timestamp"],
        likes: post["like_count"],
        comments: post["comments_count"]
      }
    end
  rescue => e
    Rails.logger.error "Instagram API Error: #{e.message}"
    []
  end
end
