{ pkgs, lib }:

with lib;

let
  sections = pipe (fileContents ./input.txt) [
    (splitString "\n")
    (map (splitString ","))
    (map (map toElfRange))
    (map (x: {
      e1 = elemAt x 0;
      e2 = elemAt x 1;
    }))
  ];

  toElfRange = start-end:
    let splitSE = splitString "-" start-end;
    in {
      start = toInt (elemAt splitSE 0);
      end = toInt (elemAt splitSE 1);
    };
  
  eitherContainsTheOther = { e1, e2 }:
       ((e2.start <= e1.start) && (e1.end <= e2.end))
    || ((e1.start <= e2.start) && (e2.end <= e1.end));

  answer1 = pipe sections [
    (count eitherContainsTheOther)
    toString
  ];

  eitherOverlapsTheOther = { e1, e2 }:
    e1.start <= e2.end && e2.start <= e1.end;

  answer2 = pipe sections [
    (count eitherOverlapsTheOther)
    toString
  ];

in pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Task2:
    ${answer2}
''