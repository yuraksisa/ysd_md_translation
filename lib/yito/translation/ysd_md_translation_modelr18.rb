require 'r18n-core' unless defined?R18n::I18n

module Yito
  module Translation
    #
    #
    #
    module ModelR18 

      def check_r18n!(thread_local_var, path)

        locale = ['es','en','it','fr','ca']

        if Thread.current[:model_locale]
           locale.insert(0, Thread.current[:model_locale])
        end

        if Thread.current[thread_local_var].nil? or locale.first != Thread.current[thread_local_var].locale.code
          Thread.current[thread_local_var] = R18n::I18n.new(locale, path)
        end
        Thread.current[thread_local_var]

      end

    end #ModelR18
  end #Translation
end #Yito