#==============================================================================
# SpellingCorrector class suggests spelling corrections for an input word. It
# also provides other info like word frequencies.
#
# Based on http://norvig.com/spell-correct.html
#
# Evan Kuhn, 2011-07-10
#==============================================================================
require 'net/http'
require 'uri'
require 'spelling_corrector'

class NorvigSpellingCorrector < SpellingCorrector
  #----------------------------------------------------------------------------
  public
  #----------------------------------------------------------------------------
  
  # Get the number of times a word appears in our corpus
  def word_count(word)
    @word_counts[word]
  end

  # Get the frequency (0 to 1) of a word appearing in our corpus
  def word_freq(word)
    count = @word_counts[word.downcase]
    count = 1 if count == 0
    return (count.to_f / @total_words.to_f)
  end

  # Get the number of unique words in our corpus
  def corpus_size
    @total_words
  end

  #----------------------------------------------------------------------------
  private
  #----------------------------------------------------------------------------
  
  def initialize
    super
    initialize_word_frequency
  end

  # Fetch a whole bunch of text so we can analyze word frequency
  def initialize_word_frequency
    # Check if we've cached our training corpus, from which we'll count word
    # frequencies.
    if(File.exists?(@@CORPUS_FILE))
      # Read the text from the file
      print "Reading corpus from disk..."
      STDOUT.flush
      text = File.read(@@CORPUS_FILE)
      puts "done"
    else
      # Read the text from the web and cache to our file on disk
      print "Reading corpus from web and caching to disk..."
      STDOUT.flush
      text = Net::HTTP.get(URI.parse(@@CORPUS_URL))
      file = File.new(@@CORPUS_FILE, 'w')
      file.write(text)
      file.close
      puts "done"
    end

    # Count each word, and the total number of valid words
    print "Counting unique words..."
    STDOUT.flush
    @word_counts = Hash.new(0)
    @total_words = 0
    
    text.split(/\s|--/).each do |x|
      x.downcase!
      # Make sure it's a word, and strip out punctuation
      if(x =~ /([a-zA-Z-]+)/)
        x = $1
        if(is_correct?(x))
          @word_counts[$1.downcase] += 1
          @total_words += 1
        end
      end
    end
    puts "done (#{@word_counts.size} found)"
  end

  # Implementation of correct()
  def correct_impl(word)
    word.downcase!

    # If the word is correctly spelled, return it
    return [word] if(is_correct?(word))

    # Get the words that are 1 edit-distance away
    words_dist1 = words_edit1(word)

    # Get the words that are 2 edits away
    words_dist2 = []
    words_dist1.each do |x|
      words_dist2.push(words_edit1(x))
    end
    words_dist2.flatten!

    # Get the valid words that are:
    # - 1 edit away
    # - 2 edits away and not also 1 edit away
    words1 = Hash.new
    words2 = Hash.new

    words_dist1.each do |x|
      words1[x] = 1 if(is_correct?(x));
    end

    words_dist2.each do |x|
      words2[x] = 1 if(!words1.has_key?(x) && is_correct?(x))
    end

    # Construct the list of suggested corrections: 1-edit words first, followed
    # by 2-edit words.
    # TODO - here's where we can fiddle with the sorting. We're assuming that
    #        words with edit-distance of 1 are always more likely to be the
    #        correct answer.  But we could also say that edit distance 1 has a
    #        75% chance of being right, and edit distance of 2 is 25%. Multiply
    #        that by the word frequency in the corpus and we get the total
    #        probability by which we can sort
    suggestions = []
    suggestions.push(words1.keys.sort { |x,y| word_freq(y) <=> word_freq(x) } )
    suggestions.push(words2.keys.sort { |x,y| word_freq(y) <=> word_freq(x) } )
    suggestions.flatten!
    return suggestions
  end
  
  # Given a word, return all words (valid or not) that are 1 edit-distance away
  def words_edit1(word)
    edits = Hash.new

    # Perform all possible edits
    edit_remove_char(word).each { |x| edits[x] = 1 }
    edit_insert_char(word).each { |x| edits[x] = 1 }
    edit_alter_char(word) .each { |x| edits[x] = 1 }
    edit_swap_chars(word) .each { |x| edits[x] = 1 }

    return edits.keys
  end

  def edit_remove_char(word)
    edits = []
    for i in 0...word.length
      new_word = word[0,i] + word[i+1,word.length]
      edits.push(new_word)
    end
    return edits
  end

  def edit_insert_char(word)
    edits = []
    for i in 0..word.length
      @@ALPHABET.each_char do |new_char|
        new_word = String.new(word)
        new_word.insert(i, new_char)
        edits.push(new_word)
      end
    end
    return edits
  end

  def edit_alter_char(word)
    edits = []
    for i in 0...word.length
      @@ALPHABET.each_byte do |new_char|
        if(new_char != word[i])
          new_word = String.new(word)
          new_word[i] = new_char
          edits.push(new_word)
        end
      end
    end
    return edits
  end

  def edit_swap_chars(word)
    edits = []
    for i in 0...word.length-1
      new_word = String.new(word)
      temp = new_word[i]
      new_word[i] = new_word[i+1]
      new_word[i+1] = temp
      edits.push(new_word)
    end
    return edits
  end

  # Constants
  @@CORPUS_FILE = 'word-freq-corpus.txt'
  @@CORPUS_URL  = 'http://norvig.com/big.txt'
end
