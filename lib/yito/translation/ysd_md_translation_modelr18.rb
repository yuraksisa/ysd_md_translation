require 'r18n-core' unless defined?R18n::I18n

module Yito
  module Translation
    #
    #
    #
    module ModelR18 

      def check_r18n!(thread_local_var, path)
        locale = if R18n and R18n.get and R18n.get.locale
                   Array(R18n.get.locale.code) + ['es','en'].keep_if {|item| item != R18n.get.locale.code}
                 else
                   ['es','en']
                 end
    
        if Thread.current[thread_local_var].nil? or locale.first != Thread.current[thread_local_var].locale.code
          Thread.current[thread_local_var] = R18n::I18n.new(locale, path)
        end
    
        Thread.current[thread_local_var]
      end

    end #ModelR18
  end #Translation
end #Yito