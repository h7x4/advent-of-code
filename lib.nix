{ pkgs, lib }: with lib; rec {
  # Transpose a square grid
  #
  # [[a]] -> [[a]]
  transpose = grid: 
    genList (n: map ((flip elemAt) n) grid) (length grid);

  # Checks if there are any duplicate items in the list,
  # in which case it returns false.
  #
  # [a] -> Bool
  allUnique = list: list == []
                 || !(elem (head list) (tail list)) && allUnique (tail list);

  # Takes items until either a predicate fails, or the list is empty.
  #
  # (a -> Bool) -> [a] -> Int
  takeWhile = pred: xs:
    if xs == [] || !(stopPred (head xs))
      then []
      else [(head xs)] + (takeWhile pred (tail xs));

  # Counts items until either a predicate fails, or the list is empty
  #
  # (a -> Bool) -> [a] -> Int
  countWhile = pred: xs: length (takeWhile head xs);

  # Like foldl, but keeps all intermediate values
  #
  # (b -> a -> b) -> b -> [a] -> [b]
  scanl = f: x1: list: let
    x2 = head list;
    x1' = f x1 x2;
  in if list == [] then [] else [x1'] ++ (scanl f x1' (tail list));

  # Like scanl, but uses the first element as its start element.
  #
  # (a -> a -> a) -> [a] -> [a]
  scanl1 = f: list: 
    if list == [] then [] else scanl f (head list) (tail list);

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

  # Trivial function to wrap around the multiplication operation.
  #
  # Number -> Number -> Number
  multiply = x: y: x * y;

  # Trivial function to take the absolute value of a number
  #
  # Number -> Number
  abs = x: if x < 0 then -x else x;

  # Generate a list by repeating an element n times.
  #
  # a -> Int -> [a]
  repeat = item: times: map (const item) (range 1 times);

  # Compare two items, return either 1, 0, or -1 depending on whether
  # one is bigger than the other.
  #
  # Ord a => a -> a -> Int
  cmp = x: y: if x > y then 1 else if x < y then -1 else 0;

  # Take 1 item, and skip the n-1 next items continuosly until the list is empty.
  #
  # Int -> [a] -> [a]
  takeWithStride = n: l:
    if l == [] then [] else [(head l)] ++ takeWithStride n (drop n l);

  # Split a list at every n items.
  #
  # Int -> [a] -> [[a]]
  chunksOf = n: list: if list == []
                        then []
                        else [(take n list)] ++ (chunksOf n (drop n list));

  # Map something orderable through a function f if it is between min and max.
  #
  # Ord a => a -> a -> (a -> b) -> a -> Either a b
  mapRange = min: max: f: o: if min <= o && o < max then f o else o;

  # Shift a number n by an offset if it is between min and max.
  #
  # Number -> Number -> Number -> Number -> Number
  transformRange = min: max: offset: n: mapRange min max (x: x + offset) n;
}
