{ pkgs, lib, ... }:

with lib;

let
  updateState = s@{ path ? [], filetree ? { } }: line: let
      splitCommand = splitString " " line;
    in if line == "$ cd /" then { path = [ "/" ]; inherit filetree; }
    else if line == "$ cd .." then { path = init path; inherit filetree; }
    else if elemAt splitCommand 1 == "cd" then { path = path ++ [(elemAt splitCommand 2)]; inherit filetree; }
    else if line == "$ ls" then s
    else if head splitCommand == "dir" then s
    else let
      newPath = path ++ [(elemAt splitCommand 1)];
      filesize = toInt (elemAt splitCommand 0);
    in {
      inherit path;
      filetree = recursiveUpdate filetree (setAttrByPath newPath filesize);
    };

    mapAttrsRecursiveToList = f: g: attrs: let
      inner = path: attrs': flatten (mapAttrsToList (attrsToListF path) attrs');
      attrsToListF = path: n: v: let newPath = path ++ [n];
                                 in if isAttrs v
                                      then g newPath (inner newPath v)
                                      else f newPath v;
    in inner [] attrs;

    backfillDirSizes = { path, size }: dirs:
      if path == []
        then dirs
        else let
               key = concatStringsSep "/" path;
               newDirs = recursiveUpdate dirs { ${key} = (dirs.${key} or 0) + size; };
             in backfillDirSizes { path = init path; inherit size; } newDirs;

    mapFiletreeToDirSizes = attrs: pipe attrs [
      (mapAttrsRecursiveToList (path: size: { inherit path size; }) (_: v: v))
      (map (x: x // { path = init x.path; }))
      (fold backfillDirSizes {})
    ];

    dirSizes = pipe ./input.txt [
      fileContents
      (splitString "\n")
      (foldl updateState { })
      (x: x.filetree)
      mapFiletreeToDirSizes
    ];

    answer1 = pipe dirSizes [
      (filterAttrs (_: v: v <= 100000))
      attrValues
      (foldr add 0)
      toString
    ];

    answer2 = pipe dirSizes [
      (filterAttrs (_: v: v >= dirSizes."/" - 40000000))
      attrValues
      (foldr min (30000000))
      toString
    ];

in pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Task2:
    ${answer2}
''
