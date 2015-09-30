require 'builder'
require 'json'
require 'byebug'
require 'middleman-blog/tag_pages'
require 'active_support/inflector'

Dir['./lib/*'].each { |f| require f }

activate :blog do |blog|
  blog.permalink = ":year/:month/:day/:title.html"
  blog.sources = "posts/:year-:month-:day-:title.html"
  blog.paginate = true
  blog.tag_template = 'category.html'
  blog.taglink = 'categories/:tag.html'
  blog.author_template = 'author.html'
  blog.authorlink = 'authors/:author.html'
end

class Utils
  def self.normalize_tag(tag)
    case tag.downcase
    when 'ember.js', 'ember', 'emberjs'
      'ember'
    when 'ember-cli', 'ember cli'
      'ember-cli'
    when 'jobs', 'job'
      'jobs'
    when 'observations', 'observation'
      'observations'
    else
      tag
    end
  end

  # Add target="_blank" to a tags that link to external sites
  def self.process_anchor_tags(body)
    # This regext will pull the quoted and escaped value for an href
    # returned value format: \"https://dockyard.com\"
    href_regex = /(?<=href=)\\?['"]([^"']*)(?:\\?["'])/

    body.gsub(href_regex) do |url|
      processed_url = url
      if is_external_url(url)
        processed_url = "#{url} target=\"_blank\""
      end

      processed_url
    end
  end

  def self.is_external_url(url)
    # This regex will match relative urls, and dockyard.com urls (including sub domains)
    # example matching urls:
    # \"https://dockyard.com\"
    # \"http://dockyard.com\"
    # \"//dockyard.com\"
    # \"http://reefpoints.dockyard.com\"
    # \"/some/relative/path\"
    internal_url_regex = /((?:http:\/\/|https:\/\/|\/\/|.+).?dockyard.com|^(?:\\"\/))/

    !url.match(internal_url_regex)
  end
end

module Middleman::Blog::BlogArticle
  def summary
    data['summary']
  end

  def tags
    article_tags = data['tags']

    if data['tags'].is_a? String
      article_tags = article_tags.split(',').map(&:strip).map { |tag| normalize_tag(tag) }
    else
      article_tags = Array.wrap(article_tags)
    end
    Array.wrap(data['legacy_category']) + article_tags
  end

  def normalize_tag(tag)
    Utils.normalize_tag(tag)
  end

  def ember_start_version
    data['ember_start_version']
  end

  def ember_end_version
    data['ember_end_version']
  end

  def ember_start_version
    data['ember_start_version']
  end

  def ember_end_version
    data['ember_end_version']
  end
end

helpers do
  def ordinal_date(date)
    number = date.day.ordinalize
    ordinal = number.slice!(-2,2)

    "#{date.strftime('%B')} #{number}<sup>#{ordinal}</sup>, #{date.strftime('%Y')}"
  end

  def tag_links(tags)
    tags.map do |tag|
      link_to tag_path(tag), class: 'post__tag' do
        "#{tag_name(tag)}&nbsp;<span class='post__tag__count'>(#{tag_count(tag)})</span>"
      end
    end.join(' ')
  end

  def articles_json
    article_hashes = blog.articles.map do |article|
      {
        id: article.url.gsub('.html', '').sub(/^\//,''),
        title: article.title,
        dockyarder: article.author.parameterize,
        body: Utils.process_anchor_tags(article.body),
        summary: article.summary,
        emberStartVersion: article.ember_start_version,
        emberEndVersion: article.ember_end_version,
        tags: article.tags.map { |tag| Utils.normalize_tag(tag).parameterize },
        shallow: article.shallow?,
        date: article.date
      }
    end

    JSON.generate(article_hashes)
  end

  def tags_json
    tags = blog.articles.map(&:tags).flatten.map { |tag| Utils.normalize_tag(tag) }.uniq
    tag_hashes = tags.map do |tag|
      {
        id: tag.parameterize,
        name: Middleman::Blog::TagPages.tag_name(tag)
      }
    end

    JSON.generate(tag_hashes)
  end

  def tag_count(tag)
    blog.articles.select { |article| article.tags.map(&:downcase).include?(tag.downcase) }.size
  end

  def tag_name(tag)
    Middleman::Blog::TagPages.tag_name(tag)
  end

  def active_state_for(path)
    page_classes.split.first == (path) ? 'active' : nil
  end

  def all_ads
    { }
  end

  def ad_partial
    all_ads[(all_ads.keys & current_page.tags).first]
  end

  def has_ad?
    (all_ads.keys & current_page.tags).any?
  end
end

set :markdown_engine, :redcarpet
set :markdown, :tables => true, :layout_engine => :erb, :fenced_code_blocks => true, :lax_html_blocks => true, :renderer => ::Highlighter::HighlightedHTML.new
activate :highlighter
activate :author_pages
activate :legacy_category
activate :asset_hash, ignore: /images/
ignore 'author.html.haml'
page 'sitemap.xml', layout: false
page 'new_sitemap.xml', layout: false
page 'atom.xml', layout: false
page 'new_atom.xml', layout: false
page 'posts.json', layout: false

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :haml, remove_whitespace: true
