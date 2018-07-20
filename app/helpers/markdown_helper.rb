module MarkdownHelper
  def markdown(text)
    if text.is_a?(String)
      markdown_renderer.render(text).to_html.html_safe # rubocop:disable Rails/OutputSafety
    end
  end

  def markdown_renderer
    @markdown_renderer ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        filter_html: true,
        hard_wrap: true,
        no_images: true,
        no_styles: true
      ),
      strikethrough: true,
      underline: true,
      autolink: true
    )
  end
end
