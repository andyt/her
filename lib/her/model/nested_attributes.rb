module Her
  module Model
    module NestedAttributes
      extend ActiveSupport::Concern

      module ClassMethods
        # Allow nested attributes for an association
        #
        # @example
        #   class User
        #     include Her::Model
        #
        #     has_one :role
        #     accepts_nested_attributes_for :role
        #   end
        #
        #   class Role
        #     include Her::Model
        #   end
        #
        #   user = User.new(name: "Tobias", role_attributes: { title: "moderator" })
        #   user.role # => #<Role title="moderator">
        def accepts_nested_attributes_for(*associations)
          allowed_association_names = association_names

          associations.each do |association_name|
            unless allowed_association_names.include?(association_name)
              raise Her::Errors::AssociationUnknownError, "Unknown association name :#{association_name}"
            end

            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              if method_defined?(:#{association_name}_attributes=)
                remove_method(:#{association_name}_attributes=)
              end

              def #{association_name}_attributes=(attributes)
                self.#{association_name}.assign_nested_attributes(attributes)
              end
            RUBY
          end
        end
      end
    end
  end
end
