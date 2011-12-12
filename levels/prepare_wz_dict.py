# A simple program to take in a book, and output the words with their frequency, for use as a
# dictionary to create levels for Word Zombies.

# Description: Takes input on stdin, and will output to stdout in the following format
# Usage: cat somefile.txt | python prepare_wz_dict.py
# <word> <freq>\n

from string import punctuation
import sys

# Grab all the words from the input
words_gen = (word.strip(punctuation).lower() 
                for line in sys.stdin.readlines()
                for word in line.split())

# Count occurences
words = {}
for word in words_gen:
    words[word] = words.get(word, 0) + 1

# Output to stdout in correct format
for word, frequency in words.items():
    print "%s %d" % (word, frequency)
