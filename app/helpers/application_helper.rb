module ApplicationHelper
  def render_markdown(text)
    return "" if text.blank?

    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(text)
  end
end
