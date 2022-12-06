{ pkgs, lib }:

with lib;

let
  input = stringToCharacters (fileContents ./input.txt);

  foldl'' = f: l: let
    initial = take 2 l;
    base = f (elemAt initial 0) (elemAt initial 1);
  in foldl f base (drop 2 l);

  zipLists = ls: let 
    minLength = foldl'' min (map length ls);

    f = n: pipe ls [
      (map (l: elemAt l n))
      (imap0 (i: nameValuePair (toString i)))
      listToAttrs
    ];
  in genList f minLength;

  zipNSelfDrop1 = n: l: 
    zipLists (map (i: drop i l) (range 0 (n - 1)));

  countUntil = pred: l: let
    innerCount = list: count:
      if pred (head list)
        then count
        else innerCount (tail list) (count + 1);
  in innerCount l 0;

  allItemsAreUnique = l: l == []
                      || (!(elem (head l) (tail l))
                         && allItemsAreUnique (tail l));

  answerN = n: pipe input [
    (zipNSelfDrop1 n)
    (map attrValues)
    (countUntil allItemsAreUnique)
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
