require 'data_mapper' unless defined?DataMapper
require 'ysd_md_cms' unless defined?ContentManagerSystem
module Model
  module Translation
    module CMS
        
      #
      # Content Translation
      #  
      # It represents the translation of a content
      #
      class ContentTranslation
        include ::DataMapper::Resource
      
        storage_names[:default] = 'trans_content_translation'
        
        property :content_id, String, :length => 32, :field => 'content_id', :key => true
        belongs_to :translation, 'Model::Translation::Translation', :child_key => [:translation_id], :parent_key => [:id]
        
        #
        # Creates or updates the content translation
        #
        def self.create_or_update(content_id, language_code, attributes)
        
          content_translation = nil
          
          ContentTranslation.transaction do 
         
            content_translation = ContentTranslation.get(content_id)                  
          
            if content_translation
              content_translation.set_translated_attributes(language_code, attributes)
            else
              translation = Model::Translation::Translation.create_with_terms(language_code, attributes) 
              content_translation = ContentTranslation.create({:content_id => content_id, :translation => translation})
            end
            
          end
          
          content_translation
        
        end
        
        #
        # Find the content translated attributes 
        #
        # @param [String] language_code
        #  The language
        #
        # @return [Array]
        #  An array of TranslationTerm which contains the translated terms associated to the content
        #
        #
        def get_translated_attributes(language_code)
        
          Model::Translation::TranslationTerm.find_translations_by_language(translation.id, language_code)
        
        end
        
        #
        # Updates the translated attributes
        #
        # @param [String] language_code
        #  The language
        #
        # @param [Hash] attributes
        #  The attributes with the translations
        #
        #
        def set_translated_attributes(language_code, attributes)
        
          translation.update_terms(language_code, attributes)
        
        end
        
      end
      
      #
      # Term translation
      #
      class TermTranslation
        include ::DataMapper::Resource

        storage_names[:default] = 'trans_term_translation'
 
        belongs_to :term, 'ContentManagerSystem::Term', :child_key => [:term_id], :parent_key => [:id], :key => true
        belongs_to :translation, 'Model::Translation::Translation', :child_key => [:translation_id], :parent_key => [:id]
        
        #
        # Creates or updates a term translation
        #
        def self.create_or_update(term_id, language_code, attributes)
       
          term_translation = nil
          
          TermTranslation.transaction do 

            term_translation = TermTranslation.get(term_id)
            
            if term_translation
              term_translation.set_translated_attributes(language_code, attributes)            
            else
              translation = Model::Translation::Translation.create_with_terms(language_code, attributes) 
              term_translation = TermTranslation.create({:term => ::ContentManagerSystem::Term.get(term_id), 
                                                         :translation => translation})
            end
             
          end       
        
          term_translation
        
        end
        
        #
        # Get the term translated attributes
        #
        # @param [String] language_code
        #  The language code
        #
        # @return [Array]
        #  An array of TranslationTerm which contains all the translations terms in the request language
        #
        def get_translated_attributes(language_code)
        
          Model::Translation::TranslationTerm.find_translations_by_language(translation.id, language_code)
        
        end
        
        #
        # Updates the translated attributes
        #
        # @param [Numeric] term_id
        #  The term id
        #
        # @param [String] language_code
        #  The language code
        #
        # @param [Hash] attributes
        #  The attributes
        #
        def set_translated_attributes(language_code, attributes)
        
          translation.update_terms(language_code, attributes)
        
        end
        
        
      end
    
    end
  end
end

module ContentManagerSystem
  
  class Content
  
    attr_accessor :language_code
  
    #
    # Translate the content into the language code
    #
    # @param [String] language_code
    #  The language ISO 639-1 code
    #
    # @return [Content]
    #  A new instance of ContentManagerSystem::Content with the translated attributes
    #
    def translate(language_code)
      
      content = nil
    
      if content_translation = ::Model::Translation::CMS::ContentTranslation.get(key)
        translated_attributes = {}
        content_translation.get_translated_attributes(language_code).each {|term| translated_attributes.store(term.concept.to_sym, term.translated_text)}
        content = Content.new(key, attributes.merge(translated_attributes){ |key, old_value, new_value| new_value.to_s.strip.length > 0?new_value:old_value }) 
      else
        content = self       
      end
      
      content.language_code = language_code
    
      content
    
    end
  
    alias old_get_categories get_categories 
  
    #
    # Retrieve the categories (translated)
    #
    def get_categories
        
      if not instance_variable_get(:@full_translated_categories) 
       if language_code
         @full_translated_categories = old_get_categories.map { |term| term.translate(language_code) }
       else
         @full_translated_categories = old_get_categories        
       end
      end
      
      @full_translated_categories
    
    end
  
  end
  
  class Term
    
    attr_accessor :language_code
    
    #
    # Translate the term into the language code
    #
    # @param [String] language_code
    #  The language ISO 639-1 code
    #
    # @return [Term]
    #  A new instance of the ContentManagerSystem::Term with the translated attributes
    #
    def translate(language_code)
    
      term = nil
      
      if term_translation = ::Model::Translation::CMS::TermTranslation.get(id)
        translated_attributes = {}
        term_translation.get_translated_attributes(language_code).each {|term| translated_attributes.store(term.concept.to_sym, term.translated_text)}
        term = Term.new(attributes.merge(translated_attributes){ |key, old_value, new_value| new_value.to_s.strip.length > 0?new_value:old_value})
      else
        term = self
      end
    
      term.language_code = language_code
    
      term
      
    end
  
  end
  
end