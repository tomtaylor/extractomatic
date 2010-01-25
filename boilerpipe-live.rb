require 'sinatra'
require 'haml'
require 'json'

# We're using r68 from trunk because of an HTML encoding fix
require 'jars/boilerpipe-1.0-r68.jar'
require 'jars/nekohtml-1.9.13.jar'
require 'jars/xerces-2.9.1.jar'

java_import "java.net.URL"
java_import "de.l3s.boilerpipe.extractors.ArticleExtractor"
java_import "de.l3s.boilerpipe.extractors.ArticleSentencesExtractor"
java_import "de.l3s.boilerpipe.extractors.KeepEverythingWithMinKWordsExtractor"
java_import "de.l3s.boilerpipe.extractors.DefaultExtractor"
java_import "de.l3s.boilerpipe.extractors.LargestContentExtractor"
java_import "de.l3s.boilerpipe.extractors.NumWordsRulesExtractor"

mime :json, "application/json"
set :haml, {:format => :html5 }

class UnknownExtractor < Exception; end
class NoUrlPresent < Exception; end

get '/' do
  haml :index
end

get '/extract' do
  content_type :json
  
  begin
    url_string = params[:url]
    mode = params[:mode] || "default"
    
    extractors = {
      'article' => ArticleExtractor,
      'article_sentences' => ArticleSentencesExtractor,
      'min_k_words' => KeepEverythingWithMinKWordsExtractor,
      'default' => DefaultExtractor,
      'largest' => LargestContentExtractor,
      'num_words' => NumWordsRulesExtractor
    }
    
    raise NoUrlPresent unless url_string && url_string.length > 0
    raise UnknownExtractor unless extractors.keys.include?(mode)
    
    url = URL.new(url_string)
    content = extractors[mode].instance.getText(url)
    
  rescue java.net.MalformedURLException
    return_error("Malformed URL", 100)
  rescue java.lang.RuntimeException
    return_error("Could not connect", 101)
  rescue UnknownExtractor
    return_error("Unknown extractor mode", 102)
  rescue
    return_error("Unknown error", 99)
  else
    return_success(content, url_string)
  end
end

private

def return_error(message, code)
  {
    :error => {
      :message => message,
      :code => code
    },
    :status => "error"
  }.to_json
end

def return_success(content, url)
  {
    :response => {
      :content => content,
      :url => url
    },
    :status => "success"
  }.to_json
end