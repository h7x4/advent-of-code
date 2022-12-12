{ pkgs, lib }:

with lib;

let
  mapDirectionStepsToHorizontalVertical = { direction, steps }: {
    horizontal = if direction == "L" then steps else
                 if direction == "R" then -steps else 0;
    vertical = if direction == "D" then steps else
               if direction == "U" then -steps else 0;
  };

  scanl = f: x1: list: let
    x2 = head list;
    x1' = f x1 x2;
  in if list == [] then [] else [x1'] ++ (scanl f x1' (tail list));

  foldHeadPosition =
    { x ? 0, y ? 0 }: 
    { horizontal, vertical }: {
      x = x + horizontal;
      y = y + vertical;
    };

  movements = pipe ./input.txt [
    fileContents
    (splitString "\n")
    (map (splitString " "))
    (map (x: { direction = head x; steps = toInt (elemAt x 1); }))
    (map mapDirectionStepsToHorizontalVertical)
    (scanl foldHeadPosition {})
  ];

  abs = x: if x < 0 then -x else x;

  ropePieceLength = headPiece: tailPiece: let
    deltaX = abs (headPiece.x - tailPiece.x);
    deltaY = abs (headPiece.y - tailPiece.y);
  in max deltaX deltaY;

  moveRopePiece = headPiece: tailPiece: {
    x = if headPiece.x > tailPiece.x then tailPiece.x + 1 else
        if headPiece.x < tailPiece.x then tailPiece.x - 1 else 
                                          tailPiece.x;
    y = if headPiece.y > tailPiece.y then tailPiece.y + 1 else
        if headPiece.y < tailPiece.y then tailPiece.y - 1 else 
                                          tailPiece.y;
  };

  moveRope = headToOverlap: rope: let
    newHead = moveRopePiece headToOverlap (head rope);
    moveIfNextPieceMoved = x: y:
      if ropePieceLength x y > 1
        then moveRopePiece x y
        else y;
    newTail = scanl moveIfNextPieceMoved newHead (tail rope);
  in [newHead] ++ newTail;

  moveRopeUntilHeadOverlapsAndReportLastPositions = headToOverlap: rope: let
    newRope = moveRope headToOverlap rope;
    nextIteration = moveRopeUntilHeadOverlapsAndReportLastPositions headToOverlap newRope;
  in if head rope == headToOverlap
       then {
         inherit rope;
         tailPositions = [];
       }
       else {
         inherit (nextIteration) rope;
         tailPositions = [(last newRope)] ++ nextIteration.tailPositions;
        };

  repeat = item: times: map (const item) (range 1 times);

  f = n: { rope ? (repeat { x = 0; y = 0; } n), tailPositions ? [{ x = 0; y = 0; }] }: newHeadPosition: let
    newRope = moveRopeUntilHeadOverlapsAndReportLastPositions newHeadPosition rope;
  in {
    rope = newRope.rope;
    tailPositions = tailPositions ++ newRope.tailPositions;
  };

  answer1 = pipe movements [
    (foldl (f 2) {})
    (x: x.tailPositions)
    unique
    length
    toString
  ];

  answer2 = pipe movements [
    (foldl (f 10) {})
    (x: x.tailPositions)
    unique
    length
    toString
  ];

in pkgs.writeText "answers" ''
  Task1:
    ${answer1}

  Task2:
    ${answer2}
''
