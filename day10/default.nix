{ pkgs, lib, AoCLib, ... }:

with lib;

let
  inherit (AoCLib) toInt repeat takeWithStride chunksOf;

  lineToInstruction = line:
    if line == "noop"
      then { type = "n"; }
      else { type = "a"; val = toInt (elemAt (splitString " " line) 1); };

  foldToSignalState = { cycles ? 0, X ? 0, nextX ? 1 }: instructions: let
    instr = head instructions;
    nextSignalState = if instr.type == "n" 
                        then { cycles = 1; X = nextX; inherit nextX; }
                        # Implicit `addx`
                        else { cycles = 2; X = nextX; nextX = nextX + instr.val; };
  in if instructions == [] then [] else [nextSignalState] ++ (foldToSignalState nextSignalState (tail instructions));

  expandSignalStates = signalStates: let
    s = head signalStates;
  in if signalStates == []
       then []
       else (repeat s.X s.cycles) ++ (expandSignalStates (tail signalStates));

  signalStates = pipe ./input.txt [
    fileContents
    (splitString "\n")
    (map lineToInstruction)
    (foldToSignalState {})
    expandSignalStates
  ];

  answer1 = pipe signalStates [
    (imap1 (i: v: i * v))
    (drop 19)
    (takeWithStride 40)
    (foldr add 0)
    toString
  ];

  f = i: v: if v <= i && i <= v + 2 then "#" else ".";

  answer2 = pipe signalStates [
    (chunksOf 40)
    (map (imap1 f))
    (map (concatStringsSep ""))
    (concatStringsSep "\n")
    toString
  ];

in pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Task2:
  ${answer2}
''
