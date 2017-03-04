require 'byebug'
require 'rubygems'
require 'algoliasearch'
require 'active_support/all'

module Jekyll

  class RequestPage < Page
    def initialize(site, base, dir, request, id)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'request.html')
      self.data['request'] = request

      self.data['id'] = id
      self.data['title'] = request[1]
      self.data['status'] = request[2]
      self.data['receiver'] = request[3]
      self.data['creation_date'] = request[4]
      self.data['resolution_date'] = request[5]
      self.data['author_name'] = request[6]
      self.data['author_twitter_handle'] = request[7]
      self.data['category'] = request[8]
      self.data['author_organization'] = request[9]
      self.data['request_text'] = request[10]
      self.data['resolution_text'] = request[11]
      self.data['resolution_data_url'] = request[12]
      self.data['request_pdf_url'] = request[13]
      self.data['resolution_pdf_url'] = request[14]
      self.data['author_email'] = request[15]
      self.data['author_notes'] = request[16]
    end
  end

  class RequestPageGenerator < Generator
    safe true

    def generate(site)
      Algolia.init application_id: ENV['ALGOLIA_APPLICATION_ID'], api_key: ENV['ALGOLIA_API_KEY']

      if site.layouts.key? 'request'
        dir = 'peticiones'
        site.data['google_sheet'][1..-1].sort{|a,b| Time.parse(a[0]) <=> Time.parse(b[0])}.each_with_index do |request, id|
          id+=1
          request_page = RequestPage.new(site, site.source, File.join(dir, id.to_s), request, id)
          site.collections['requests'].docs << request_page
          index(request_page)
        end
      end
    end

    private

    def index(request_page)
      index = Algolia::Index.new("petitions")
      #index.set_settings({"searchableAttributes" => ["title", "author_name", "receiver", "author_twitter_handle", "category", "author_organization"]})

      index.add_object(request_page.data.except(*ignored_attributes).merge('objectID' => request_page.data['id']))
    end

    def ignored_attributes
      %W{ id request layout creation_date resolution_date resolution_data_url request_pdf_url resolution_pdf_url author_email author_notes }
    end
  end

end
