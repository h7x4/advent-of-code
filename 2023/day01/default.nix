{ pkgs, lib }:

with lib;

let
  input = pipe (fileContents ./input.txt) [
    (splitString "\n")
  ];

  answer1 = pipe input [
    (map stringToCharacters)
    (x: {
      forwards = x;
      reverse = map reverseList x;
    })
    (mapAttrs (_: map (findFirst (x: builtins.match "[[:digit:]]" x == [ ]) null)))
    ({ forwards, reverse }: zipListsWith (a: b: a + b) forwards reverse)
    (map toInt)
    (foldr (a: b: a + b) 0)
    toString
  ];

  letterNumbers = {
    "one"   = "1";
    "two"   = "2";
    "three" = "3";
    "four"  = "4";
    "five"  = "5";
    "six"   = "6";
    "seven" = "7";
    "eight" = "8";
    "nine"  = "9";
  };

  reverseString = s: pipe s [
    stringToCharacters
    reverseList
    (builtins.concatStringsSep "")
  ];

  # NOTE: builtins.match somehow always matches the last group first.
  #       I believe it might be an implementation detail.
  answer2 = pipe input [
    (x: {
      last = pipe x [
        (map (builtins.match "^.*([[:digit:]]|${builtins.concatStringsSep "|" (builtins.attrNames letterNumbers)}).*$"))
        (map head)
      ];
      first = pipe x [
        (map reverseString)
        (let
          rLetterNumbers = map reverseString (builtins.attrNames letterNumbers);
        in map (builtins.match "^.*([[:digit:]]|${builtins.concatStringsSep "|" rLetterNumbers}).*$"))
        (map head)
        (map reverseString)
      ];
    })
    (mapAttrs (_: map (x: letterNumbers.${x} or x)))
    ({ first, last }: zipListsWith (a: b: a + b) first last)
    (map toInt)
    (foldr (a: b: a + b) 0)
    toString
  ];
  
in
  pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Task2:
    ${answer2}
''
