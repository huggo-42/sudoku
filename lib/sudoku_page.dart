import 'package:flutter/material.dart';
import 'package:sudoku/box_class.dart';
import 'package:sudoku/utils/print_tool.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

import 'colors.dart';
import 'helpers/index.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  List<List<int>> newSudoku = [];
  List<List<int>> newSudokuSolved = [];
  Board board = Board();

  void genSudoku() {
    SudokuGenerator sudokuGenerator = SudokuGenerator(emptySquares: 54);
    newSudoku = sudokuGenerator.newSudoku;
    newSudokuSolved = sudokuGenerator.newSudokuSolved;

    for (int i = 0; i < newSudokuSolved.length; ++i) {
      for (int j = 0; j < newSudokuSolved[i].length; ++j) {
        int boxIndex = getBoxIndex(i, j);
        int rowIndex = getRowIndex(boxIndex);
        int indexInRow = getIndexInRow(rowIndex, boxIndex);
        bool isSolved = newSudoku[rowIndex][indexInRow] ==
            newSudokuSolved[rowIndex][indexInRow];
        Box box = Box(
          value: newSudoku[rowIndex][indexInRow],
          correctValue: newSudokuSolved[rowIndex][indexInRow],
          boxIndex: boxIndex,
          block: i,
          row: getRowIndex(boxIndex),
          col: getColIndex(boxIndex),
          isSolved: isSolved,
        );
        board.append(box);
      }
    }
  }

  void printSudoku() {
    for (int i = 0; i < 9; i++) {
      printTool(newSudoku[i].toString());
    }
    printTool('');

    for (int i = 0; i < 9; i++) {
      printTool(newSudokuSolved[i].toString());
    }
    printTool('');
  }

  @override
  void initState() {
    genSudoku();

    super.initState();
  }

  int selectedValue = -1;
  int selectedIndex = -1;

  void boxSelected(int index, int idx) {
    board.setAllBoxHighlightToFalse();
    int boxIndex = getBoxIndex(index, idx);
    int rowIndex = getRowIndex(boxIndex);
    int colIndex = getColIndex(boxIndex);
    selectedValue = board.getBox(boxIndex).value;
    selectedIndex = boxIndex;
    printTool("Box selected index: $boxIndex");
    printTool("Box selected row: $rowIndex");
    printTool("Box selected column: $colIndex");

    // go through Box in row and set then to HIGHLIGHT
    // go through Box in column and set then to HIGHLIGHT
    List<int> indexesToHighlight = [];
    for (int i = 0; i < IndexHelper.rows[rowIndex]!.length; ++i) {
      indexesToHighlight.add(IndexHelper.rows[rowIndex]![i]);
    }
    for (int i = 0; i < IndexHelper.cols[colIndex]!.length; ++i) {
      indexesToHighlight.add(IndexHelper.cols[colIndex]![i]);
    }
    // for (int i in indexesToHighlight) {
    //   printTool("indexesToHighlight: $i");
    // }
    for (int i in indexesToHighlight) {
      board.getBox(i).isHighlight = true;
    }
    var value = board.getBox(boxIndex).value;
    if (value != 0) {
      for (Box box in board.boxes.values) {
        if (box.value == value) {
          box.isHighlight = true;
        }
      }
    }
    setState(() {});
  }

  void validateBoard() {
    int solved = 0;
    for (Box box in board.boxes.values) {
      if (box.value == box.correctValue) ++solved;
    }
    String snackBarMessage;
    if (solved == 81) {
      snackBarMessage = "SOLVED";
    } else {
      snackBarMessage = "NOT SOLVED";
    }
    SnackBar snackBar = SnackBar(content: Text(snackBarMessage));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create new game?'),
          actions: <Widget>[
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close,
                size: 30,
                color: blue400,
              ),
              label: const Text(
                'Cancel',
                style: TextStyle(
                  color: blue400,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(blue100),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.done,
                size: 30,
                color: blue400,
              ),
              label: const Text(
                'OK',
                style: TextStyle(
                  color: blue400,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(blue100),
              ),
            ),
          ],
        );
      },
    );
  }

  void newBoard() async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create new game?'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(
              Icons.close,
              size: 30,
              color: blue400,
            ),
            label: const Text(
              'Cancel',
              style: TextStyle(
                color: blue400,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(blue100),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(
              Icons.done,
              size: 30,
              color: blue400,
            ),
            label: const Text(
              'OK',
              style: TextStyle(
                color: blue400,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(blue100),
            ),
          ),
        ],
      ),
    );
    if (confirm) {
      genSudoku();
      setState(() {});
    }
  }

  void handleKeyboardPress(int input) {
    Box box = board.getBox(selectedIndex);
    if (box.value != box.correctValue) {
      box.value = input;
      // boxSelected(rowIndex, getIndexInRow(rowIndex, selectedIndex));
      // int rowIndex = getRowIndex(selectedIndex);
      // int indexInRow = getIndexInRow(rowIndex, selectedIndex);
      // printTool("[DEBUG] input: $input, selectedIndex: $selectedIndex");
      // printTool("[DEBUG] rowIndex: $rowIndex, indexInRow: $indexInRow");
      int blockIndex = box.block;
      int inBlockIndex = getIndexInBlock(box.block, box.boxIndex);
      boxSelected(blockIndex, inBlockIndex);
      printTool("[DEBUG] blockIndex: $blockIndex, inBlockIndex: $inBlockIndex");
      setState(() {});
    }
  }

  void eraseBox() {
    Box box = board.getBox(selectedIndex);
    if (box.value != box.correctValue) {
      box.value = 0;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    int getBoxValue(int index, int idx) {
      return board.getBox(getBoxIndex(index, idx)).value;
      // return newSudokuSolved[getRowIndex(getBoxIndex(index, idx))][
      //     getIndexInRow(
      //         getRowIndex(getBoxIndex(index, idx)), getBoxIndex(index, idx))];
    }

    printSudoku();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sudoku FOSS",
          style: TextStyle(
            color: blue400,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(5),
              alignment: Alignment.center,
              child: GridView.builder(
                itemCount: 9,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  // crossAxisSpacing: 5,
                  // mainAxisSpacing: 5,
                ),
                physics: const ScrollPhysics(),
                itemBuilder: (BuildContext ctx, int index) {
                  List<int> bottomAdd = [6, 7, 8];
                  List<int> leftAdd = [0, 3, 6];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: const BorderSide(
                          color: blue600,
                          width: 1.5,
                        ),
                        left: BorderSide(
                          color: blue600,
                          width: leftAdd.contains(index) ? 1.5 : 0,
                        ),
                        right: const BorderSide(
                          color: blue600,
                          width: 1.5,
                        ),
                        bottom: BorderSide(
                          color: blue600,
                          width: bottomAdd.contains(index) ? 2 : 0,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: GridView.builder(
                      // itemCount: boxInner.blokChars.length,
                      itemCount: 9,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                        // crossAxisSpacing: 2,
                        // mainAxisSpacing: 2,
                      ),
                      physics: const ScrollPhysics(),
                      itemBuilder: (BuildContext buildContext, int idx) {
                        Box box =
                            board.getBoxByBlockIndexAndInBlockIndex(index, idx);
                        Color color = white;
                        Color colorText = blue500;
                        if (box.isHighlight) {
                          color = blue100;
                        }
                        if (box.value == selectedValue && selectedValue != 0) {
                          color = blue200;
                        }
                        if (box.value != box.correctValue) {
                          colorText = Colors.red;
                        }

                        List<int> shouldHaveBottomRight = [0, 1, 3, 4];
                        List<int> shouldHaveBottom = [2, 5];
                        List<int> shouldHaveLeft = [7, 8];
                        double bottomBorderWidth = 0;
                        if (shouldHaveBottomRight.contains(idx) ||
                            shouldHaveBottom.contains(idx)) {
                          bottomBorderWidth = .5;
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: color,
                            // TODO: HERE MEN
                            border: Border(
                              left: BorderSide(
                                color: colorText,
                                width: shouldHaveLeft.contains(idx) ? .5 : 0,
                              ),
                              right: BorderSide(
                                color: colorText,
                                width: shouldHaveBottomRight.contains(idx)
                                    ? .5
                                    : 0,
                              ),
                              bottom: BorderSide(
                                color: colorText,
                                width: bottomBorderWidth,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () => boxSelected(index, idx),
                            style: TextButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(0),
                                ),
                              ),
                            ),
                            child: Text(
                              /**
                              * 1. index = block
                              * 2. idx = index in block
                              * ------------------------------------------
                              * Getting a value from newSudokuSolved
                              * newSudoku[rowIndex][insideRowIndex]
                              */
                              // "${getBoxValue(index, idx)}",
                              board
                                          .getBoxByBlockIndexAndInBlockIndex(
                                              index, idx)
                                          .value ==
                                      0
                                  ? ''
                                  : board
                                          .getBoxByBlockIndexAndInBlockIndex(
                                              index, idx)
                                          .value
                                          .toString() ??
                                      '',
                              style: TextStyle(
                                color: colorText,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: GridView.builder(
                itemCount: 9,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  // crossAxisCount: 9,
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 2,
                ),
                physics: const ScrollPhysics(),
                itemBuilder: (BuildContext buildContext, int idx) {
                  return TextButton(
                    onPressed: () => handleKeyboardPress(idx + 1),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      backgroundColor: blue100,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(0),
                        ),
                      ),
                    ),
                    child: Text(
                      "${idx + 1}",
                      style: const TextStyle(
                        fontSize: 20,
                        color: blue500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => newBoard(),
                  icon: const Icon(
                    Icons.add,
                    size: 30,
                    color: blue400,
                  ),
                  label: const Text(
                    'New game',
                    style: TextStyle(
                      color: blue400,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(blue100),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    IconButton(
                      onPressed: () => eraseBox(),
                      icon: const Icon(
                        Icons.clear,
                        size: 30,
                        color: blue400,
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(blue100),
                      ),
                    ),
                    const Text(
                      'Erase',
                      style: TextStyle(
                        color: blue400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     board.printBoardState();
      //   },
      //   child: const Icon(Icons.adb),
      // ),
    );
  }
}

int getBoxIndex(int blockIndex, int inBlockIndex, {bool debug = false}) {
  int boxIndex = -1;
  boxIndex = IndexHelper.blocks[blockIndex]![inBlockIndex];
  if (debug) {
    printTool("INSIDE getBoxIndex");
    printTool("blockIndex: $blockIndex, inBlockIndex: $inBlockIndex");
    printTool("boxIndex: $boxIndex");
  }
  return boxIndex;
}

int getRowIndex(int boxIndex, {bool debug = false}) {
  int rowIndex = -1;
  IndexHelper.rows.forEach((key, value) {
    if (value.contains(boxIndex)) {
      rowIndex = key;
    }
  });
  if (debug) {
    printTool("INSIDE getRowIndex");
    printTool("boxIndex: $boxIndex");
    printTool("rowIndex: $rowIndex");
  }
  return rowIndex;
}

int getColIndex(int boxIndex, {bool debug = false}) {
  int colIndex = -1;
  IndexHelper.cols.forEach((key, value) {
    if (value.contains(boxIndex)) {
      colIndex = key;
    }
  });
  if (debug) {
    printTool("INSIDE getColIndex");
    printTool("boxIndex: $boxIndex");
    printTool("colIndex: $colIndex");
  }
  return colIndex;
}

int getIndexInRow(int rowIndex, int boxIndex, {bool debug = false}) {
  int a = -1;
  a = IndexHelper.rows[rowIndex]!.indexOf(boxIndex);
  if (debug) {
    printTool("INSIDE getIndexInRow");
    printTool("rowIndex: $rowIndex, boxIndex: $boxIndex");
    printTool("rowIndex: $rowIndex, boxIndex: $boxIndex");
  }
  return a;
}

int getIndexInBlock(int blockIndex, int boxIndex) {
  int a = -1;
  a = IndexHelper.blocks[blockIndex]!.indexOf(boxIndex);
  return a;
}
