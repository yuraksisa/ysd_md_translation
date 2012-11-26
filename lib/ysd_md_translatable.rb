require 'ysd-plugins' unless defined?Plugins::ModelAspect
module Model
  #
  # It defines an aspect to manage translations
  #
  module Translatable
    include ::Plugins::ModelAspect

  end
end