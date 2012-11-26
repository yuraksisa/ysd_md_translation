require 'data_mapper' unless defined?DataMapper

module Model
  module Translation

    #
    # Each instance of translation term represents a translated concept
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
      
    end #TranslationTerm

  end #Translation
end #Model