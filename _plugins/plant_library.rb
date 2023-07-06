require 'uri'


module Plants
    class FilteredPage < Jekyll::Page

      include Jekyll::Filters

      def initialize(site, base, dir, country = nil, location = nil, collection = nil)
        @site = site
        @base = base
        @ext = ".html"

        # Country
        if country != nil and location == nil
          @dir = dir + country + ext
          @dir.gsub!(/\s/,'_')
          @plants = site.collections['plants'].docs.select { |doc| doc.data['country'] == country }

        # Country and location
        elsif country != nil and location != nil
          @dir = dir + country + "_" + location + ext
          @dir.gsub!(/\s/,'_')
          @plants = site.collections['plants'].docs.select { |doc| doc.data['country'] == country and doc.data['location'] == location }

        # All plants
        else
          @dir = dir + "all" + ext
          @plants = site.collections['plants'].docs
        end

        @data = {
          'layout' => 'plant_filter',
          'category' => collection,
          'plants' => @plants,
          'style' => '/assets/css/plants.css'
          'country' => country,
          'location' => location
        }
      end

      def url_placeholders
        {
          :path       => @dir,
          :category   => 'plants',
          :basename   => basename,
          :output_ext => output_ext,
        }
      end

    end



    class Generator < Jekyll::Generator
      def generate(site)
        # Get all countries in the plant collection
        countries = site.collections['plants'].docs.map { |doc| doc.data['country'] }.uniq

        site.data['plant_countries'] = countries

        # Get all locations by country
        locations = {}
        for country in countries
          locations[country] = site.collections['plants'].docs.select { |doc| doc.data['country'] == country }.map { |doc| doc.data['location'] }.uniq
        end

        site.data['plant_locations'] = locations

        Jekyll.logger.info "countries:", site.data['plant_countries']
        Jekyll.logger.info "locations:", site.data['plant_locations']

        # Page for all plants
        page = FilteredPage.new(site, site.source, '/plants/')
        site.pages << page

        for country in countries
          # Create a new page for each country
          page = FilteredPage.new(site, site.source, '/plants/', country)
          site.pages << page

          # Create a new page for each location in the country
          for location in locations[country]
            page = FilteredPage.new(site, site.source, '/plants/', country, location)
            site.pages << page
          end
        end
      end
    end
end