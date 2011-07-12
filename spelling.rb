require 'spelling_corrector'

corrector = SpellingCorrector.new

while(1)
  print "Gimme a word> "
  word = gets
  word.chomp!
  word.downcase!

  #puts word
  #puts " - correct: #{corrector.is_correct?(word)}" 
  #puts " - count:   #{corrector.word_count(word)}"
  #puts " - corpus:  #{corrector.corpus_size}" 
  #puts " - freq:    #{corrector.word_freq(word)}"

  puts "Top 10 corrections for \"#{word}\""
  corrections = corrector.correct(word)
  for i in 0...(corrections.size < 10 ? corrections.size : 10)
    puts corrections[i]
  end
  puts ""
  
end
