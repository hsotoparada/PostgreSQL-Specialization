#!/usr/bin/env python
# coding: utf-8

# Puzzle: Break a Hashing Function
# In this assignment we will write a simple hashing function that uses addition and multiplication
# and then find a pair of strings that will return the same hash value for different strings
# (i.e you will cause a Hash Collision).

# The algorithm uses multiplication based on the position of a letter in the hash to avoid a
# hash collision when two letters are transposed like in 'ABCDE' and 'ABDCE'.
# Your strings need to be at least three characters long and no more than 10 characters long.

while True:
    txt = input("Enter a string: ")
    if len(txt) < 1: break

    hv = 0
    pos = 0
    for let in txt:
        pos = (pos % 3) + 1
        hv = (hv + (pos * ord(let))) % 1000000
        print(let, pos, ord(let), hv)

    print(hv, txt)

