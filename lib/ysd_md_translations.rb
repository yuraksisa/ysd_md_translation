require 'data_mapper' unless defined?DataMapper

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
        search_options.store(:offet, options[:offset]) if options.has_key?(:offset)
    
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
  
    end
  
    # 
    # It's used to group all the terms of a concept translation
    #
    class Translation
      include ::DataMapper::Resource

      storage_names[:default] = 'trans_translation'
    
      property :id, Serial, :field => 'id', :key => true      
      has n, :translation_terms, 'TranslationTerm', :child_key => [:translation_id], :parent_key => [:id], :constraint => :destroy
    
      #
      # Creates a translation in the specified language code with the related attributes
      #
      # @param [String] language_code
      #  The language
      #
      # @param [Hash] terms
      #  The terms
      #
      def self.create_with_terms(language_code, terms)
      
        translation_language = TranslationLanguage.get(language_code)
        
        translation = Translation.new
        
        terms.each do |attribute, value|
          
          if value and value.to_s.strip.length > 0
            translation_term = TranslationTerm.new({:concept => attribute, 
                                                  :translated_text => value, 
                                                  :translation_language => translation_language})
            translation.translation_terms << translation_term
          end
                  
        end
        
        translation.save
        
        translation
      
      end
    
      #
      # Update the translated terms
      #
      def update_terms(language_code, attributes)
      
        translation_language = TranslationLanguage.get(language_code)
      
        Translation.transaction do
      
          attributes.each do |attribute, value|
        
            if term = TranslationTerm.get_term(self, translation_language, attribute)
              term.translation = value
              term.save
            else
              TranslationTerm.create({:concept => attribute, 
                                      :translated_text => value, 
                                      :translation_language => translation_language,
                                      :translation => self})
            end
            
          end
        
        end
        
        translation_terms.reload
      
      end
    
    end
     
    #
    # Each instance of translation term represents the
    #
    class TranslationTerm
      include ::DataMapper::Resource

      storage_names[:default] = 'trans_translation_term'
    
      property :id, Serial, :field => 'id', :key => true            # The id
      
      property :concept, String, :length => 64, :field => 'concept'   # It represents the term concept (name, title, description, ...)
      property :translated_text, Text, :field => 'translated_text'  # The translated text
      
      belongs_to :translation_language, 'TranslationLanguage', :child_key => [:translation_language_code], :parent_key => [:code]
      belongs_to :translation, 'Translation', :child_key => [:translation_id], :parent_key => [:id]
      
      #
      # Find the terms which have been translated into a language
      #
      # @param [Number] translation_id
      #
      #  The translation of the terms
      #
      # @param [String] language_code
      #
      #  The language code
      #
      def self.find_translations_by_language(translation_id, language_code)
      
        terms_by_language=all(:translation => {:id => translation_id}, :translation_language => {:code => language_code})
      
      end
      
      #
      # Get a translation term
      #
      # @param [Translation] translation
      #   The translation
      #
      # @param [TranslationLanguage] translation_language
      #   The translation language
      #
      # @param [String] concept
      #   The translation concept
      #
      def self.get_term(translation, translation_language, concept) 
      
        TranslationTerm.first({:translation => translation, :translation_language => translation_language, :concept => concept})
      
      end
      
    end
    
  end #Translation
end #Model