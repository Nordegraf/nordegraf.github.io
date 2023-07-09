require 'uri'
require 'json'


module Plants

    class PlantRenderer < Jekyll::Renderer
      def initialize(site, plants, site_payload = nil)
        @site     = site
        @payload  = site_payload
        @layouts  = nil
        @plants   = plants
      end

      def place_in_layout?
        if @document == @plants.last
          Jekyll.logger.info "Plant Picture Library:" , "Emplace"
          super
        else
          false
        end
      end


      def run
        rendered = ""
        for plant in @plants
          @document = plant
          rendered += super
          if plant != @plants.last
            rendered += "<hr>"
          end
        end

        # emplace merged pages into default layout
        @document.content = rendered
        @document.data['layout'] = 'titled'
        @document.data['title'] = @plants.first.data['name']
        @document.data['render_with_liquid'] = false

        info = {
          :registers        => { :site => site, :page => payload["page"] },
          :strict_filters   => liquid_options["strict_filters"],
          :strict_variables => liquid_options["strict_variables"],
        }

        output = place_in_layouts(rendered, payload, info)

        output
      end
    end

    class PlantPage < Jekyll::Page

      def initialize(site, base, dir, name, plants)
        @site = site
        @base = base
        @ext = ".html"

        @dir = dir + name + ext
        @dir.gsub!(' ', '_')
        @dir.downcase!

        @tags = []

        @plants = plants

        # sort plants
        @plants.sort_by! { |plant| plant.url }

        @renderer = PlantRenderer.new(site, @plants)

        generate_tags()

        # not sure which plant is picked for the page
        # therefore add tags to all plants
        @plants.each do |plant|
          plant.data['tags'] = @tags
        end

        @data = {
          'layout' => 'none',
          'style' => '/assets/css/plants.css',
          'plant' => plants.first,
        }
      end

      def generate_tags()
        for plant in @plants
          for attr in site.data["filter_attributes"]
            tag = plant.data[attr]
            unless tag.nil? or @tags.include? tag
              @tags << tag
            end
          end
        end
      end
    end

    class PlantThumbPage < Jekyll::Page

      include Jekyll::Filters

      def initialize(site, base, dir, id, plant)
        @site = site
        @base = base
        @ext = ".html"
        @entries = 0

        @dir = dir + id.to_s + ext

        @data = {
          'layout' => 'plant_thumb',
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

    class PlantPageGenerator < Jekyll::Generator
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

        # render all plant pages
        site.collections['plants'].docs.each_with_index do |doc, i|
          same_plants = []
          same_plants << doc
          for other_doc in site.collections['plants'].docs
            if other_doc.data['name'] == doc.data['name'] and other_doc != doc
              same_plants << other_doc
              site.collections['plants'].docs.delete(other_doc)
            end
          end

          page = PlantPage.new(site, site.source, '/plants/', doc.data['name'], same_plants)
          site.pages << page
        end

        Jekyll.logger.info "Plant Picture Library:" , "Generated Plant Picture Library"
      end
    end

    class PlantThumbGenerator < Jekyll::Generator
      def generate(site)
        # collect all other attributes
        site.collections['plants'].docs.each_with_index do |doc, i|
          doc.data['oid'] = i
          page = PlantThumbPage.new(site, site.source, '/plants/', i, doc)
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