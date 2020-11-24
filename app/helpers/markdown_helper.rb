module MarkdownHelper
  def markdown(text)
    if text.is_a?(String)
      markdown_renderer.render(text).html_safe # rubocop:disable Rails/OutputSafety
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
      autolink: true,
      tables: true
    )
  end

  def markdown_line_break_to_paragraph(text)
    if text.is_a?(String)
      lines = ArrayUtils.trim(text.split(/\n/))
      lines.map do |line|
        markdown_renderer.render(line)
      end.join(' ').html_safe # rubocop:disable Rails/OutputSafety
    end
  end
end
