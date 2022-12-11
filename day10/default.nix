{ pkgs, lib }:

with lib;

let
  # See https://github.com/NixOS/nixpkgs/pull/205457
  toInt = str:
    let
      inherit (builtins) match fromJSON;
      # RegEx: Match any leading whitespace, possibly a '-', one or more digits,
      # and finally match any trailing whitespace.
      strippedInput = match "[[:space:]]*(-?[[:digit:]]+)[[:space:]]*" str;

      # RegEx: Match a leading '0' then one or more digits.
      isLeadingZero = match "0[[:digit:]]+" (head strippedInput) == [];

      # Attempt to parse input
      parsedInput = fromJSON (head strippedInput);

      generalError = "toInt: Could not convert ${escapeNixString str} to int.";

      octalAmbigError = "toInt: Ambiguity in interpretation of ${escapeNixString str}"
      + " between octal and zero padded integer.";

    in
      # Error on presence of non digit characters.
      if strippedInput == null
      then throw generalError
      # Error on presence of leading zero/octal ambiguity.
      else if isLeadingZero
      then throw octalAmbigError
      # Error if parse function fails.
      else if !isInt parsedInput
      then throw generalError
      # Return result.
      else parsedInput;

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

  repeat = item: times: map (const item) (range 1 times);

  expandSignalStates = signalStates: let
    s = head signalStates;
  in if signalStates == []
       then []
       else (repeat s.X s.cycles) ++ (expandSignalStates (tail signalStates));

  takeWithStride = n: l:
    if l == [] then [] else [(head l)] ++ takeWithStride n (drop n l);

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

  splitAtInterval = n: list:
    if list == [] then []
                  else [(take n list)] ++ (splitAtInterval n (drop n list));

  f = i: v: if v <= i && i <= v + 2 then "#" else ".";

  answer2 = pipe signalStates [
    (splitAtInterval 40)
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
