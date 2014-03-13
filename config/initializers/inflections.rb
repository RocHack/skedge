# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end

module Paperclip
	module Schema
	    def self.included(base)
	    end
    end
end	

# module Paperclip
# class HasAttachedFile
# def add_active_record_callbacks
# name = @name
# @klass.send(:after_save) { send(name).send(:save) }
# @klass.send(:before_destroy) { send(name).send(:queue_all_for_delete) }
# if @klass.respond_to?(:after_commit)
# @klass.send(:after_commit, :on => :destroy) { send(name).send(:flush_deletes) }
# else
# @klass.send(:after_destroy) { send(name).send(:flush_deletes) }
# end
# end
# end
# end