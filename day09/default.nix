{ pkgs, lib, AoCLib, ... }:

with lib;

let
  inherit (AoCLib) scanl abs repeat cmp;

  mapDirectionStepsToHorizontalVertical = { direction, steps }: {
    horizontal = if direction == "L" then steps else
                 if direction == "R" then -steps else 0;
    vertical = if direction == "D" then steps else
               if direction == "U" then -steps else 0;
  };

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

  ropePieceLength = headPiece: tailPiece: let
    deltaX = abs (headPiece.x - tailPiece.x);
    deltaY = abs (headPiece.y - tailPiece.y);
  in max deltaX deltaY;

  moveRopePiece = headPiece: tailPiece: {
    x = tailPiece.x + (cmp headPiece.x tailPiece.x);
    y = tailPiece.y + (cmp headPiece.y tailPiece.y);
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
