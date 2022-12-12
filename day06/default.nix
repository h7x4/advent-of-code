{ pkgs, lib, AoCLib, ... }:

with lib;

let
  inherit (AoCLib) allUnique;

  countWithNUntil = n: pred: list: let
    inner = list': count:
      if pred (take n list')
        then count
        else inner (tail list') (count + 1);
  in inner list 0;

  answerN = n: pipe ./input.txt [
    fileContents
    stringToCharacters
    (countWithNUntil n allUnique)
    (add n)
    toString
  ];

  answer1 = answerN 4;
  answer2 = answerN 14;
in pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Task2:
    ${answer2}
''
