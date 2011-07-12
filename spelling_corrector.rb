#==============================================================================
# SpellingCorrector base class
#
# Evan Kuhn, 2011-07-10
#==============================================================================

class SpellingCorrector
  #----------------------------------------------------------------------------
  public
  #----------------------------------------------------------------------------

  # Get the number of words in our dictionary
  def dict_size
    return @dictionary.size
  end
  
  # Is the word recognized by our dictionary?
  def is_correct?(word)
    @dictionary.has_key?(word)
  end

  # Correct a given spelling
  # - Takes the input word to correct.
  # - Returns the suggested spelling corrections, sorted from most probable to
  #   least probable.
  def correct(word)
    return correct_impl(word)
  end

  #----------------------------------------------------------------------------
  private
  #----------------------------------------------------------------------------
  
  def initialize
    initialize_dictionary
  end

  # Initialize our dictionary
  def initialize_dictionary
    @dictionary = Hash.new
    file = File.open(@@DICTIONARY_FILE)
    file.each_line do |x|
      x.chomp!
      @dictionary[x.downcase] = 1
    end
  end

  # Constants
  @@DICTIONARY_FILE = '/usr/share/dict/words'
  @@ALPHABET        = 'abcdefghijklmnopqrstuvwxyz'
end
