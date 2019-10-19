# frozen_string_literal: true

require 'net/http'
require 'json'
require 'hashie'

class Derpibooru
  attr_accessor :sfw_filter, :nsfw_filter, :api_key, :hidden_tags

  def initialize(**args)
    @api_base     = args[:api_base] || 'https://derpibooru.org'
    @api_key      = args[:key]
    @sfw_filter   = args[:sfw_filter] || '100073'
    @nsfw_filter  = args[:nsfw_filter] || '56027'
    @hidden_tags  = args[:hidden_tags] || {}
  end

  def import_config(cfg)
    return if cfg.nil?

    @api_base     = cfg['api_url'] || @api_base
    @api_key      = cfg['api_key'] || @api_key
    @sfw_filter   = cfg['sfw_filter'] || @sfw_filter
    @nsfw_filter  = cfg['nsfw_filter'] || @nsfw_filter
    @hidden_tags  = cfg['hidden_tags'] || @hidden_tags
  end

  private

  # stolen from concerns/sluggable.rb
  def generate_slug(name)
    new_name = name.dup

    # Escape common punctuation.
    new_name.gsub!('-', '-dash-')
    new_name.gsub!('/', '-fwslash-')
    new_name.gsub!('\\', '-bwslash-')
    new_name.gsub!(':', '-colon-')
    new_name.gsub!('.', '-dot-')
    new_name.gsub!('+', '-plus-')

    # Render into URL encoding. For URLs dipsit.
    CGI.escape(new_name).gsub('%20', '+')
  end

  def get(**args)
    args[:url] ||= args[:link] || args[:uri]
    args[:query] ||= args[:params]

    uri = URI "#{@api_base}/#{args[:url]}"

    uri.query = args[:query].to_s               if args[:query]
    uri.query = "#{uri.query}&key=#{@api_key}"  if @api_key.present?
    uri.query = "#{uri.query}#{uri.query.present? ? '&' : ''}filter_id=#{args[:nsfw] ? @nsfw_filter : @sfw_filter}"

    response = Net::HTTP.get_response uri

    Hashie::Mash.new JSON.parse(response.body) if response.class == Net::HTTPOK
  end

  public

  def image(id, nsfw = false)
    get url: "#{id}.json", nsfw: nsfw
  end

  def tag(t)
    get url: "/tags/#{generate_slug(t)}.json", nsfw: true
  end

  def search(query, nsfw = false)
    get url: 'search.json', query: "q=#{query}", nsfw: nsfw
  end

  def random_image(query = 'safe, cute', nsfw = false)
    img = get(url: 'search.json', query: "q=#{query.present? ? query : 'safe, cute'}&random_image=1", nsfw: nsfw)
    image img.id, nsfw if img
  end
end
