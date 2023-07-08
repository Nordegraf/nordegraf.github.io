require 'uri'
require 'json'


module Plants
    class FilteredPage < Jekyll::Page

      include Jekyll::Filters

      def initialize(site, base, dir, id, plant)
        @site = site
        @base = base
        @ext = ".html"
        @entries = 0

        @dir = dir + id.to_s + ext

        @data = {
          'layout' => 'plant_filter',
          'plant' => plant,
          'style' => '/assets/css/plants.css',
          'oid' => id,
          'name' => plant.data['name']
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

      def entries()
        @entries
      end

    end


    class Generator < Jekyll::Generator
      def generate(site)
        # collect all possible attributes
        site.data["filter_attributes"] = []
        site.data["filter_values"] = {}

        # get all attributes from the config file
        site.config['plant_attributes'].each do |attr|
          attr[1].each { |v|
            site.data["filter_attributes"] << v
          }
        end

        for attr in site.data["filter_attributes"]
          site.data["filter_values"][attr] = site.collections['plants'].docs.map { |doc| doc.data[attr] }.uniq
        end

        # collect all other attributes

        site.collections['plants'].docs.each_with_index do |doc, i|
          doc.data['oid'] = i
          page = FilteredPage.new(site, site.source, '/plants/', i, doc)
          site.pages << page
        end

        filter_classes(site, site.collections['plants'].docs[0])
      end

      def filter_classes(site, doc)
        classes = {}
        for doc in site.collections['plants'].docs
          for cat in site.config["plant_attributes"].keys
            cl = ""
            for attr in site.config["plant_attributes"][cat]
              unless doc.data[attr].nil?
                # split lists and add each value as a class
                value = doc.data[attr].gsub(/ /, '_')
                cl += value + " "
                classes[attr + ";" + value] = cl
              end
            end
          end
        end
        site.data["filter_classes"] = classes
        Jekyll.logger.info "classes: ", classes
      end

      def jsonfy_plant_attributes(site, doc)
        jsonstring = "{"
        for cat in site.config["plant_attributes"].keys
          num_attr = site.config["plant_attributes"][cat].length
          first_attr = site.config["plant_attributes"][cat].first
          jsonstring += "\"#{first_attr}\": ["

          for attr in site.config["plant_attributes"][cat]
            if attr == site.config["plant_attributes"][cat].last
              jsonstring += "\"#{doc.data[attr]}\""
              for i in 1..num_attr-1
                jsonstring += "]}"
              end
            else
              jsonstring += "{\"#{doc.data[attr]}\": ["
            end
          end
          jsonstring += "]"
          unless cat == site.config["plant_attributes"].keys.last
            jsonstring += ","
          end
        end
        jsonstring += "}"

        doc.data['attr_json'] = jsonstring
        Jekyll.logger.info "JSON: ", jsonstring
      end

      def generate_attribute_hierarchy(site)
        for doc in site.collections['plants'].docs
          jsonfy_plant_attributes(site, doc)
        end

        data = {}
        for doc in site.collections['plants'].docs
          docdata = JSON.load(doc.data['attr_json'])
          data = merge_recursively(data, docdata)
        end

        Jekyll.logger.info "data: ", data
        site.data["filter_hierarchy"] = data
      end

      def merge_recursively(a, b)
        if a.is_a?(Hash) && b.is_a?(Hash)
          a.merge(b) {|key, a_item, b_item| merge_recursively(a_item, b_item) }
        elsif a.is_a?(Array) && b.is_a?(Array)
          newl = a | b
          # if array content are hashes, merge them
          if a[0].is_a?(Hash) && b[0].is_a?(Hash)
            newl = []
            for i in 0..a.length-1
              newl << merge_recursively(a[i], b[i])
            end
          end

          newl
        else
          b
        end
      end

    end
end