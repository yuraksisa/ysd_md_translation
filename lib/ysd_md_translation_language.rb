module Model
  module Translation
  
    #
    # One instance for each of the language which can be used to translate
    #
    # ISO 639-1 language code
    #
    class TranslationLanguage
      include ::DataMapper::Resource

      storage_names[:default] = 'trans_translation_language'
      
      property :code, String, :length => 2, :field => 'code', :key => true
      property :description, String, :length => 64, :field => 'description' 
  
      #
      # Find all languages except the default language
      #
      # @return [Array]
      #  languages which are differents from the default language
      #
      def self.find_translatable_languages
      
        default_language = ::SystemConfiguration::Variable.get_value('default_language')     
        TranslationLanguage.all.select { |translation_language| translation_language.code != default_language }
      
      end
    
      #
      # Retrieve all translation languages
      #
      # @param [Hash] options
      #
      def self.find_all(options={})
              
        search_options = {}        
        search_options.store(:limit, options[:limit]) if options.has_key?(:limit)
        search_options.store(:offset, options[:offset]) if options.has_key?(:offset)
    
        count = options[:count] || true
        result = []
      
        result << TranslationLanguage.all(search_options)
      
        if count
          begin
            result << TranslationLanguage.count
          rescue
            result << TranslationLanguage.all.length
          end
        end
      
        if result.length == 1
          result = result.first
        end
      
        result
      
      end
  
    end #TranslationLanguage
  end #Translation
end #Model
