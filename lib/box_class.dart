import 'helpers/index.dart';
import 'utils/print_tool.dart';

class Board {
  Map<int, Box> boxes = {};

  void append(Box box) {
    boxes[box.boxIndex] = box;
  }

  Box getBox(int boxIndex) {
    return boxes[boxIndex]!;
  }

  Box getBoxByBlockIndexAndInBlockIndex(int blockIndex, int inBlockIndex) {
    int boxIndex = IndexHelper.blocks[blockIndex]![inBlockIndex];
    Box box = boxes[boxIndex]!;
    return box;
  }

  void setAllBoxHighlightToFalse() {
    for (Box item in boxes.values) {
      item.isHighlight = false;
    }
  }

  void printBoardState() {
    for (Box item in boxes.values) {
      printTool("");
      printTool("value: ${item.value}");
      printTool("correctValue: ${item.correctValue}");
      printTool("boxIndex: ${item.boxIndex}");
      printTool("block: ${item.block}");
      printTool("row: ${item.row}");
      printTool("col: ${item.col}");
    }
  }
}

class Box {
  int value;
  int correctValue;
  int boxIndex;
  int block;
  int row;
  int col;
  bool isSolved;
  bool isHighlight;

  Box({
    required this.value,
    required this.correctValue,
    required this.boxIndex,
    required this.block,
    required this.row,
    required this.col,
    required this.isSolved,
    this.isHighlight = false,
  });
}
