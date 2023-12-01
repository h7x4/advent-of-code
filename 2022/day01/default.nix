{ pkgs, lib, ... }:

with lib;

let 
  elves = pipe (builtins.readFile ./input.txt) [
    (splitString "\n\n")
    (map (splitString "\n"))
    (map (map toInt))
    (map (fold add 0))
  ];

  answer1 = toString (fold max (-1) elves);

  max3 = abc: x: if x >= abc.a then { a = x; b = abc.a; c = abc.b; } else
                 if x >= abc.b then { a = abc.a; b = x; c = abc.b; } else
                 if x >= abc.c then { inherit (abc) a b; c = x; } else
                 abc;

  answer2 = pipe elves [
    (foldl max3 { a = -1; b = -1; c = -1; })
    (abc: abc.a + abc.b + abc.c)
    toString
  ];

in pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Task2:
    ${answer2}
''
