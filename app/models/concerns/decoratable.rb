module Decoratable
  extend ActiveSupport::Concern
  
  def decorate
    class << self
      include "#{self.superclass}Decorator".constantize
    end
    self
  end
end