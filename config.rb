require 'contentful'
require 'rich_text_renderer'
require 'redcarpet'
require 'redcarpet/render_strip'

client = Contentful::Client.new(
  access_token: ENV['CONTENTFUL_DELIVERY_API_KEY'],
  space: ENV['CONTENTFUL_SPACE_ID']
)

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

helpers do
  # Custom helper for converting Rich Text to HTML
  def rich_text_to_html(value)
    renderer = RichTextRenderer::Renderer.new
    renderer.render(value)
  end

  # Custom helper for convert Markdown to HTML
  def markdown_to_html(value)
    renderer = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      autolink: false,
      tables: true,
      escape_html: false
    )

    renderer.render(value)
  end
end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# configure :build do
#   activate :minify_css
#   activate :minify_javascript, compressor: Terser.new
# end

# Query entries that match the content type 'Page'.
# Parameter `include` is set to 0, since we don't need related entries.
# Parameter `limit` value set as 10 for development, 1000 for build.
pages = client.entries(
  content_type: 'page',
  include: 0,
  select: 'fields.slug',
  limit: build? ? 1000 : 10
)

# Map the 'Slug' field values of 'Page' entries into a flat array.
page_slugs = pages.map do |page|
  page.fields[:slug]
end

# Query 'Pages' entry and set corresponding proxy.
page_slugs.each do |page_slug|
  # Query 'Page' entry by 'Slug' field value.
  page = client.entries(
    content_type: 'page',
    include: 2,
    "fields.slug": page_slug
  ).first

# Set proxy for 'Slug' field value and pass 'Page' entry's data to template.
  proxy "/pages/#{page_slug}/index.html", '/pages/page.html', locals: {
    page:
  }
end

ignore '/pages/page.html'
