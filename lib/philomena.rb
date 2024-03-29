# frozen_string_literal: true

require 'net/http'
require 'json'
require 'hashie'

# Philomena API backend class.
# @author Luna aka Meow the Cat
# @attr [String, Number] sfw_filter The ID of the SFW filter to use.
# @attr [String, Number] nsfw_filter The ID of the NSFW filter to use.
# @attr [String] api_key Booru-on-Rails API key.
# @attr [Array<String, Array<String>>] hidden_tags The array of tags to forcibly hide.
class Philomena
  attr_accessor :sfw_filter, :nsfw_filter, :api_key, :hidden_tags, :no_search_tags

  # Initializes a new API fetcher
  # @param (see `import_config`)
  def initialize(**args)
    @api_base           = args[:api_base] || 'https://philomena.local/api/v1/json'
    @api_key            = args[:key]
    @sfw_filter         = args[:sfw_filter] || '1'
    @nsfw_filter        = args[:nsfw_filter] || '2'
    @everything_filter  = args[:everything_filter] || '2'
    @hidden_tags        = args[:hidden_tags] || []
    @no_search_tags     = args[:no_search_tags] || []
  end

  # Imports configuration.
  # @note This would be the `booru` field of the YAML config.
  # @param cfg [Hash] configuration JSON Hash.
  def import_config(cfg)
    return if cfg.nil?

    @api_base           = "#{cfg['url_base']}/api/v1/json" || @api_base
    @api_key            = cfg['api_key'] || @api_key
    @sfw_filter         = cfg['sfw_filter'] || @sfw_filter
    @nsfw_filter        = cfg['nsfw_filter'] || @nsfw_filter
    @everything_filter  = cfg['everything_filter'] || @everything_filter
    @hidden_tags        = cfg['hidden_tags'] || @hidden_tags
    @no_search_tags     = cfg['no_search_tags'] || @no_search_tags
  end

  private

  # @private
  # Generates a booru slug from name. Removes dangerous characters and encodes the strin as URL component.
  # @note Stolen from concerns/sluggable.rb
  # @param name [String] name to generate the slug for.
  # @return [String] safe name, a slug.
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

  # @private
  # Fetches the API with the given parameters.
  # @param args [Hash] the options for the query.
  # @option args [String] :url the URL to fetch, base URL is automatically prepended.
  # @option args [String] :query the query to append.
  # @option args [Boolean] :nsfw `true` to use NSFW filter, `false` to use SFW filter.
  # @option args [Number] :filter filter ID override.
  # @return [Hashie::Mash] Query result, `nil` if nothing is found.
  def get(**args)
    args[:url] ||= args[:link] || args[:uri]
    args[:query] ||= args[:params]
    filter_id = args[:filter] || (args[:nsfw] ? @nsfw_filter : @sfw_filter)

    uri = URI "#{@api_base}/#{args[:url]}"

    uri.query = args[:query].to_s if args[:query]
    uri.query = "#{uri.query}&key=#{@api_key}" if @api_key.present?
    uri.query = "#{uri.query}#{uri.query.present? ? '&' : ''}filter_id=#{filter_id}"

    response = Net::HTTP.get_response uri

    Hashie::Mash.new JSON.parse(response.body) if response.class == Net::HTTPOK
  end

  public

  # Fetches the image data with the given ID.
  # @param id [Number] the image ID.
  # @param nsfw [Boolean] Whether to use the NSFW filter or not.
  # @return [Hashie::Mash, nil] Query result, `nil` if nothing is found.
  def image(id, nsfw = false)
    img = get url: "images/#{id}", nsfw: nsfw
    img['image'] if img
  end

  # Fetches the data for the given tag. Does no filtering at all.
  # @param t [String] tag name, NOT slug.
  # @return [Hashie::Mash, nil] Query result, `nil` if nothing is found.
  def tag(t)
    tag = get url: "tags/#{generate_slug(t)}", filter: @everything_filter
    tag.tag if tag
  end

  # Searches for images based on the given query.
  # @param args [Hash] the options for the query.
  # @option args [String] :query Booru query, exactly as you would write it into the search box.
  # @option args [Boolean] :nsfw `true` to use NSFW filter, `false` to use SFW filter.
  # @option args [Number] :filter filter ID override.
  # @return [Hashie::Mash, nil] Query result, `nil` if nothing is found.
  def search(**args)
    get url: 'search/images', query: "q=#{args[:query]}", nsfw: args[:nsfw], filter: args[:filter]
  end

  # Picks a random image from a search query.
  # @param query [String] Booru query, exactly as you would write it into the search box.
  # @param nsfw [Boolean] Whether to use the NSFW filter or not.
  # @return [Hashie::Mash, nil] Query result, `nil` if nothing is found.
  def random_image(query = 'safe, cute', nsfw = false)
    img = get(url: 'search/images', query: "q=#{query.present? ? query : 'safe, cute'}&sf=random&per_page=1", nsfw: nsfw)

    if img
      img_data = img['images'][0]
      image img_data.id, nsfw if img_data
    end
  end
end
