require 'norvig_spelling_corrector'
require 'bigram_spelling_corrector'

norvig = NorvigSpellingCorrector.new
bigram = BigramSpellingCorrector.new

while(1)
  print "Gimme a word> "
  word = gets
  word.chomp!
  word.downcase!

  break if(word =~ /^quit|exit$/);

  #puts word
  #puts " - correct: #{norvig.is_correct?(word)}" 
  #puts " - count:   #{norvig.word_count(word)}"
  #puts " - corpus:  #{norvig.corpus_size}" 
  #puts " - freq:    #{norvig.word_freq(word)}"

  puts "Top 10 corrections for \"#{word}\""
  corrections = norvig.correct(word)
  for i in 0...(corrections.size < 10 ? corrections.size : 10)
    puts corrections[i]
  end
  puts ""
end

puts 'bye!'
