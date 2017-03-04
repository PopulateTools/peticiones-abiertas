module Jekyll
  class EnvironmentVariablesGenerator < Generator
    def generate(site)
      site.config['algolia_seach_key'] = ENV['ALGOLIA_SEARCH_KEY']
      site.config['algolia_application_id'] = ENV['ALGOLIA_APPLICATION_ID']
    end
  end
end
