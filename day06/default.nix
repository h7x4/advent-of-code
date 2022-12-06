{ pkgs, lib }:

with lib;

let
  countWithNUntil = n: pred: list: let
    inner = list': count:
      if pred (take n list')
        then count
        else inner (tail list') (count + 1);
  in inner list 0;

  allItemsAreUnique = l: l == []
    || !(elem (head l) (tail l)) && allItemsAreUnique (tail l);

  answerN = n: pipe ./input.txt [
    fileContents
    stringToCharacters
    (countWithNUntil n allItemsAreUnique)
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
