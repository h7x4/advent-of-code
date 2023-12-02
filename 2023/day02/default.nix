{ pkgs, lib }:

with lib;

let
  input = pipe (fileContents ./input.txt) [
    (splitString "\n")
    (map (builtins.split ": "))
    (map (flip builtins.elemAt 2))
    (map (builtins.split "; "))
    (map (filter (x: x != [ ])))
    (map (map (builtins.split ", ")))
    (map (map (filter (x: x != [ ]))))
    (map (map (map (x: let
      s = builtins.split " " x;
      name = builtins.elemAt s 2;
      value = toInt (head s);
    in nameValuePair name value))))
    (map (map listToAttrs))
    (imap1 (id: rounds: {
      inherit id rounds;
    }))
  ];

  answer1 = pipe input [
    (builtins.filter ({ rounds, ... }:
      builtins.all ({ red ? 0, green ? 0, blue ? 0 }: red <= 12 && green <= 13 && blue <= 14) rounds
    ))
    (map ({ id, ... }: id))
    (foldr (a: b: a + b) 0)
    toString
    # (generators.toPretty { })
  ];

  answer2 = pipe input [
    (map ({ rounds, ... }: let
      max = foldr (a: b: if a > b then a else b) 0;
      maxRed = max (map ({ red ? 0, ... }: red) rounds);
      maxGreen = max (map ({ green ? 0, ... }: green) rounds);
      maxBlue = max (map ({ blue ? 0, ... }: blue) rounds);
    in maxRed * maxGreen * maxBlue))
    (foldr (a: b: a + b) 0)
    toString
  ];
in
  assert trace answer2 true;
  pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Task2:
    ${answer2}
''
