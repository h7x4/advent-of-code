{ pkgs, lib }:

with lib;

let
  input = splitString "\n\n" (fileContents ./input.txt);

  getCharOffset = index: 1 + 4 * (index - 1);

  getLineAttrs = line: pipe (range 1 9) [
    (map (n: nameValuePair (toString n) (getCharOffset n)))
    listToAttrs
    (mapAttrs (_: elemAt (stringToCharacters line)))
    (filterAttrs (_: char: char != " "))
  ];

  stack = pipe input [
    (flip elemAt 0)
    (splitString "\n")

    # remove the line with stack indices
    reverseList
    (drop 1)
    reverseList

    (map getLineAttrs)
    zipAttrs
  ];
  
  moves = pipe input [
    (flip elemAt 1)
    (splitString "\n")
    (map (s:
      let words = splitString " " s;
      in {
        amount = elemAt words 1;
        from = elemAt words 3;
        to = elemAt words 5;
      }
    ))
    (map (mapAttrs (_: toInt)))
  ];

  executeStackMove = move: stack:
    stack // {
      ${toString move.from} = drop move.amount stack.${toString move.from};
      ${toString move.to} = (reverseList (take move.amount stack.${toString move.from})) ++ stack.${toString move.to};
    };

  answer1 = pipe stack
    ((map executeStackMove moves)
    ++ [
      (mapAttrsToList (_: head))
      concatStrings
    ]);

  executeStackMove2 = move: stack:
    stack // {
      ${toString move.from} = drop move.amount stack.${toString move.from};
      ${toString move.to} = (take move.amount stack.${toString move.from}) ++ stack.${toString move.to};
    };

  answer2 = pipe stack
    ((map executeStackMove2 moves)
    ++ [
      (mapAttrsToList (_: head))
      concatStrings
    ]);

in pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Task2:
    ${answer2}
''
