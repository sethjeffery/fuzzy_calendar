require 'rails_autolink'

module ApplicationHelper
  def simple_html(content, opts={})
    auto_link(content, html: { :target => '_blank' }) do |text|
      text = text.gsub(/^https?:\/\/(www\.)/, '')
      if opts[:truncate]
        truncate(text, length: opts[:truncate])
      else
        text
      end
    end.gsub(/\n/, '<br/>').html_safe
  end
end
