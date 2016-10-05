require 'flipper/api/action'

module Flipper
  module Api
    module V1
      module Actions
        class GroupsGate < Api::Action
          route %r{api/v1/features/[^/]*/groups/[^/]*/(enable|disable)/?\Z}

          def put
            if feature_names.include?(feature_name) && Flipper.group_names.include?(group_name)
              flipper[feature_name].enable_group(group_name)
              case path_parts.last
              when "enable"
                flipper[feature_name].enable_group(group_name)
              when "disable"
                flipper[feature_name].disable_group(group_name)
              end
              json_response({}, 204)
            else
              json_response({}, 404)
            end
          end

          private

          def feature_name
            @feature_name ||= Rack::Utils.unescape(path_parts[-4])
          end

          def group_name
            @group_name ||= Rack::Utils.unescape(path_parts[-2]).to_sym
          end

          def feature_names
            @feature_names ||= flipper.adapter.features
          end
        end
      end
    end
  end
end
