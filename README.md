YSD_MD_TRANSLATION
==================

<p>This module defines the model to manage model translation</p>

<p>The API is made by the followin classes:</p>

<ul>
  <li>Model::Translation::TranslationLanguage</li>
  <li>Model::Translation::Translation</li>
</ul>

<h2>Model::TranslationLanguage</h2>

<p>They represent the language to which the translation can be done</p>

<h2>Model::Translation</h2>

<p>Represents the translation of a concept. A translation is made by a set of TranslationTerms. Each of them represents a concept attribute translated into a language.</p>

<p>For example, if you want to translate the title and body of a content in English</p>

<pre>
  require 'ysd_md_translation'
  translation=Model::Translation.create_with_terms(:en, {:title => 'The title', :body => 'The body'})
  translation.update_terms(:en, {:title => 'New title'})
</pre>