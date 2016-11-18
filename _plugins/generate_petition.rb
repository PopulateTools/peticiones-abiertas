require 'byebug'
require 'nokogiri'
require 'active_support/all'
require 'i18n'

LOCALE = Jekyll.configuration({})['lang'] # set your locale from config var

Jekyll::Hooks.register :documents, :post_render do |document|
  if document.collection.label == 'peticiones'
    parser = PetitionParser.new(document)
    document.output = parser.parse
  end
end

class PetitionParser
  def initialize(document)
    @document = document
    @html = Nokogiri::HTML(document.output)
  end

  def parse
    load_translations

    add_screenshots
    add_data_file_url
    translate_dates

    return html.to_html
  end

  private

  attr_reader :document, :html

  def add_screenshots
    node = html.search(:css, '#copia-de-la-peticin').first.next.next
    if node.name == 'p' && node.text.present? && File.file?(File.join(File.dirname(document.path), node.text))
      node.name = 'img'
      node['src'] = document.url.split('/')[0..-2].join('/') + "/#{node.text}"
      node.children = ""
    end

    node = html.search(:css, '#copia-de-la-respuesta').first.next.next
    if node.name == 'p' && node.text.present? && File.file?(File.join(File.dirname(document.path), node.text))
      node.name = 'img'
      node['src'] = document.url.split('/')[0..-2].join('/') + "/#{node.text}"
      node.children = ""
    end
  end

  def add_data_file_url
    node = html.search(:css, '#datos-aportados').first.next.next
    if node.name == 'p' && node.text.present? && File.file?(File.join(File.dirname(document.path), node.text))
      node.name = 'a'
      node['href'] = document.url.split('/')[0..-2].join('/') + "/#{node.text}"
      node['_target'] = 'blank'
    end
  end

  def translate_dates
    re = /(\d{4}-\d{1,2}-\d{1,2})/

    html.xpath("//p").each do |p|
      if p.text =~ re
        p.content = p.text.gsub(re, I18n.l(Date.parse($1), format: "%d %b %Y"))
      end
    end
  end

  def base_dir
    File.dirname(document.path)
  end

  def load_translations
    if I18n.backend.send(:translations).empty?
      I18n.backend.load_translations Dir[File.join(File.dirname(__FILE__),'../_locales/*.yml')]
      I18n.locale = LOCALE
    end
  end
end
