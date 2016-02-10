The "every possible rearrangement" part is O(N!), so that's horrible. Adding
all possible space positions is more horrible. This algorithm "works" for
6-letter input phrases but chokes on 7, and we still have a tiny
dictionary. We should be able to ignore the order of the letters and spaces.
Possible strategy:

- x Convert input phrase to letters and sort them (but don't use a set,
because it's a non-unique list)
- For each word in the dictionary, ask "are all of this word's letters
contained in the phrase's letters?" (Again, this is not a set operation - if
the word is "apple", the phrase must have two "p"s.) If so, subtract this
word's letters from the phrase's letters and recurse with the smaller phrase
and the list of words found so far. If we ever get down to an empty list of
letters form the phrase  and a non-empty list of words, we've found an
anagram. If we ever run out of words and still have letters from our phrase,
we've hit a dead end.
- While doing the above, if we fail to find a word, ensure that we don't
look for it in the recursions. Eg, if we can't find "apple" in "racecars are
rad", but we can find "are", there's no point looking for "apple" in
"racecars rad". DO NOT remove "apple" from the dictionary if we DO find it -
it may be in there again. Eg "apple apple, likes to grapple"
- Dicationary words may also be anagrams of each other. Eg, if our phrase
contains "bat", it contains "tab", because they are both examples of the
letter list "abt". Pre-process our dictionary to group these, so that
we can check for "abt" once and immediately know that any of its matching
words can be made from the phrase.
- If we can get all the above working, consider how to parallelize it

UPDATE - talked with michael. A key idea is to separate "throw out
dictionary words that can't be found in this phrase", which we do first,
from "then recurse with each word that CAN be found and its
corresponding remaining phrase."
Eg, if the phrase is "applesauce is tasty", first go through the
dictionary and notice that, eg, "potato" can't be found in this phrase.
Then when we recurse with (["apple", "sauce is tasty"], dictionary) and
(["is", "apple # tasty"], dictionary), we can use the winnowed dictionary
that doesn't contain potato. We can do this each time we recurse; it's
not wasted work to winnow the dictionary because what's left is exactly
our list of words to recurse with
Another idea Michael suggested was to first use a set or bitset to
decide whether "to" might contain "otto". If it has all the necessary
letters (it does), we can then do a slower check to see if it has them
in the necessary quantities (it doesn't). Could be O(1) vs O(N)

--

Memoize anagrams_for() via a macro:
   memoize do
     def anagrams_for(phrase, dict_entries) do
       ...
     end
   end
Yeah, I said it.
This macro will start a key-value-store child process, then
define anagrams_for(phrase, dict_entries) which
first asks the child process if it has a result before doing
the rest of its work and storing the result in the child process.
