require 'data_mapper' unless defined?DataMapper

module Model
  module Translation
  
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
          
          translation_term = TranslationTerm.new({:concept => attribute, 
                                                  :translated_text => value, 
                                                  :translation_language => translation_language})
          translation.translation_terms << translation_term
                  
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
              term.translated_text = value
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
    
    end #Translation
    
  end #Translation
end #Model