{ pkgs, lib, ... }:

with lib;

let 
  guide = pipe (builtins.readFile ./input.txt) [
    (splitString "\n")
    (map (splitString " "))
    (map (xs: { they = elemAt xs 0; you = elemAt xs 1; }))
  ];

  inherentValue = x: { A = 1; B = 2; C = 3; }.${x};
  comparativeValue = { they, you }: if they == you then 3 else
                                    if (they == "A" && you == "B")
                                    || (they == "B" && you == "C")
                                    || (they == "C" && you == "A") then 6 else
                                    0;
  score = match: comparativeValue match + inherentValue match.you;

  equalizeValueType = x: { X = "A"; Y = "B"; Z = "C"; }.${x};

  answer1 = pipe guide [
    (map (match@{ you, ... }: match // { you = equalizeValueType you; }))
    (map score)
    (foldr add 0)
    toString
  ];

  inherentValue2 = { they, you }: {
    X = { A = 3; B = 1; C = 2; };
    Y = { A = 1; B = 2; C = 3; };
    Z = { A = 2; B = 3; C = 1; };
  }.${you}.${they};
  comparativeValue2 = x: { X = 0; Y = 3; Z = 6; }.${x};
  score2 = match: comparativeValue2 match.you + inherentValue2 match;

  answer2 = pipe guide [
    (map score2)
    (foldr add 0)
    toString
  ];

in pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Task2:
    ${answer2}
''