module Opbeat
  module Normalizers
    module ActionView

      class RenderNormalizer < Normalizer
        def normalize_render payload, kind
          signature = path_for(payload[:identifier])

          [signature, kind, nil]
        end

        private

        def path_for identifier
          return "Unknown template".freeze unless path = identifier
          return path unless path.start_with?("/")

          path && relative_path(path)
        end

        def relative_path path
          root = config.view_paths.find { |p| path.start_with? p }
          type = :app

          unless root
            root = Gem.path.find { |p| path.start_with? p }
            type = :gem
          end

          return "Absolute path".freeze unless root

          start = root.length
          start += 1 if path[root.length] == "/"

          if type == :gem
            "$GEM_PATH/#{path[start, path.length]}"
          else
            path[start, path.length]
          end
        end
      end

      class RenderTemplate < RenderNormalizer
        register 'render_template.action_view'
        KIND = 'template.view'.freeze

        def normalize transaction, name, payload
          normalize_render(payload, KIND)
        end
      end

      class RenderPartial < RenderNormalizer
        register 'render_partial.action_view'
        KIND = 'template.view.partial'.freeze

        def normalize transaction, name, payload
          normalize_render(payload, KIND)
        end
      end

      class RenderCollection < RenderNormalizer
        register 'render_collection.action_view'
        KIND = 'template.view.collection'.freeze

        def normalize transaction, name, payload
          normalize_render(payload, KIND)
        end
      end
    end
  end
end
