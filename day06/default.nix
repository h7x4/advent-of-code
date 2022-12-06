{ pkgs, lib }:

with lib;

let

  input = stringToCharacters (fileContents ./input.txt);

  foldl'' = f: l: let
    initial = take 2 l;
  in foldl f (f (elemAt initial 0) (elemAt initial 1)) (drop 2 l);

  countUntil = pred: l: let
    innerCount = list: count:
      if pred (head list)
        then count
        else innerCount (drop 1 list) (count + 1);
  in innerCount l 0;

  zip4ListsWith = f: fst: snd: trd: fth:
    genList
    (n: f (elemAt fst n) (elemAt snd n) (elemAt trd n) (elemAt fth n))
    (pipe [fst snd trd fth] [
      (map length)
      (foldl'' min)
    ]);

  zip4Lists = fst: snd: trd: fth:
    zip4ListsWith (fst: snd: trd: fth: { inherit fst snd trd fth; }) fst snd trd fth;

  all4ItemsAreUnique = { fst, snd, trd, fth }: fst != snd
                                            && fst != trd
                                            && fst != fth
                                            && snd != trd
                                            && snd != fth
                                            && trd != fth;

  answer1 = pipe input [
    (l: zip4Lists l (drop 1 l) (drop 2 l) (drop 3 l))
    (countUntil all4ItemsAreUnique)
    (add 4)
    toString
  ];

  zipLists = lists: let 
    minLength = (pipe lists [
      (map length)
      (foldl'' min)
    ]);
  in genList
  (n: pipe lists [
    (map (flip elemAt n))
    (imap0 (i: nameValuePair (toString i)))
    listToAttrs
  ]) minLength;

  zipNSelfWithOffset = n: offset: l: 
    zipLists (map (i: drop (offset * i) l) (range 0 (n - 1)));

  allItemsAreUnique = l:
    if l == []
      then true
      else !(elem (head l) (drop 1 l))
        && allItemsAreUnique (drop 1 l);

  answer2 = pipe input [
    (zipNSelfWithOffset 14 1)
    (map attrValues)
    (countUntil allItemsAreUnique)
    (add 14)
    toString
  ];

in pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Task2:
    ${answer2}
''
