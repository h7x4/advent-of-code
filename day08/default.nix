{ pkgs, lib }:

with lib;

let
  calculateTreeVisibilityForLine = line: let
    updateState = { currentMax ? (-1), trees ? [] }: tree:
      if tree > currentMax then { currentMax = tree; trees = trees ++ [true]; }
                           else { inherit currentMax; trees = trees ++ [false]; };
    forwards = (foldl updateState { } line).trees;
    backwards = reverseList (foldr (flip updateState) { } line).trees;
  in zipListsWith or forwards backwards;

  transpose = grid: 
    genList (n: map ((flip elemAt) n) grid) (length grid);

  combineGridsWith = f: grid1: grid2: let
    height = length grid1;
    width = length (elemAt grid1 0);
    elemAt' = row: col: grid: elemAt (elemAt grid row) col;
    generator = row: col: f (elemAt' row col grid1) (elemAt' row col grid2);
  in genList (row: genList (col: generator row col) width) height;

  trees = pipe ./input.txt [
    fileContents
    (splitString "\n")
    (map (splitString ""))
    (map tail)
    (map init)
    (map (map toInt))
  ];

  treeVisibleGrid = pipe trees [
    (lines: { horizontal = lines; vertical = transpose lines; })
    (mapAttrs (_: map calculateTreeVisibilityForLine))
    ({horizontal, vertical}: { inherit horizontal; vertical = transpose vertical; })
    ({horizontal, vertical}: combineGridsWith or horizontal vertical)
  ];

  visualization = let
    genColor = name: command: builtins.readFile
      (pkgs.runCommand name {
        buildInputs = [ pkgs.ncurses ];
      } "tput ${command} > $out");
    red = genColor "red" "setaf 1";
    green = genColor "green" "setaf 2";
    clear = genColor "clear" "sgr0";

    greenRedTree = visible: tree:
      if visible then "${green}${tree}${clear}"
                 else "${red}${tree}${clear}";

  in pipe trees [
    (map (map toString))
    (combineGridsWith greenRedTree treeVisibleGrid)
    (map (concatStringsSep ""))
    (concatStringsSep "\n")
  ];

  answer1 = pipe treeVisibleGrid [
    (map (count id))
    (foldr add 0)
    toString
  ];

  countUntil = stopPred: xs:
    if xs == [] then 0
    else if stopPred (head xs) then 1
    else 1 + (countUntil stopPred (tail xs));

  visibleDistanceBackwards = line: let
    measure = trees: size: let
      newTree = {
        inherit size;
        viewDistance = countUntil (x: x.size >= size) trees;
      };
    in [newTree] ++ trees;
  in pipe line [
    (foldl measure [])
    (map (x: x.viewDistance))
    reverseList
  ];

  visibleDistanceHorizontal = line: let
    backwards = visibleDistanceBackwards line;
    forwards = pipe line [
      reverseList
      visibleDistanceBackwards 
      reverseList
    ];
  in zipListsWith (x: y: x * y) forwards backwards;

  answer2 = pipe trees [
    (lines: { horizontal = lines; vertical = transpose lines; })
    (mapAttrs (_: map visibleDistanceHorizontal))
    ({horizontal, vertical}: { inherit horizontal; vertical = transpose vertical; })
    ({horizontal, vertical}: combineGridsWith (x: y: x * y) horizontal vertical)
    (map (foldr max 0))
    (foldr max 0)
    toString
  ];

in pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Visualization:

  ${visualization}

  Task2:
    ${answer2}
''
