{ pkgs, lib }:

with lib;

let
  compartments = pipe (fileContents ./input.txt) [
    (splitString "\n")
  ];

  splitAtMiddle = s: {
    c1 = substring 0 ((stringLength s) / 2) s;
    c2 = substring ((stringLength s) / 2) (stringLength s) s;
  };
  charsToSet = s: foldl (set: c: set // { ${c} = true; }) { } (stringToCharacters s);
  getCommonChar = { c1, c2 }:
    findSingle
      (c: c2.${c} or false)
      "Error: no common chars"
      "Error: multiple chars"
      (attrNames c1);
  mapRange = min: max: f: i: if min <= i && i < max then f i else i;
  transformRange = min: max: offset: i: mapRange min max (x: x + offset) i;

  charValue = c: pipe c [
    lib.strings.charToInt
    (transformRange 65 91 (-(65 - 27)))
    (transformRange 97 123 (-(97 - 1)))
  ];

  answer1 = pipe compartments [
    (map splitAtMiddle)
    (map (mapAttrs (_: charsToSet)))
    (map getCommonChar)
    (map charValue)
    (foldr add 0)
    toString
  ];

  chunksOf = n: l: if length l <= n
                     then [l]
                     else [(take n l)] ++ (chunksOf n (drop n l));
  toA123 = l: {
    a1 = elemAt l 0;
    a2 = elemAt l 1;
    a3 = elemAt l 2;
  };
  getCommonChar2 = { a1, a2, a3 }:
    findSingle
      (c: a2.${c} or false && a3.${c} or false)
      "Error: no common chars"
      "Error: multiple chars"
      (attrNames a1);

  answer2 = pipe compartments [
    (chunksOf 3)
    (map toA123)
    (map (mapAttrs (_: charsToSet)))
    (map getCommonChar2)
    (map charValue)
    (foldr add 0)
    toString
  ];

in pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Task2:
    ${answer2}
''
