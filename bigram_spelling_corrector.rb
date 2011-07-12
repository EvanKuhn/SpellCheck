#==============================================================================
# A spelling corrector using bigrams.
#
# From http://www.dcs.bbk.ac.uk/~roger/spellchecking.html
#
# Evan Kuhn, 2011-07-11
#==============================================================================
require 'spelling_corrector'

class BigramSpellingCorrector < SpellingCorrector
  #----------------------------------------------------------------------------
  private
  #----------------------------------------------------------------------------
  def initialize
    super
    # TODO
  end

  # Implementation for correct()
  def correct_impl
    return [] # TODO
  end
end
