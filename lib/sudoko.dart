import 'package:flutter/material.dart';
import 'dart:math';

class SudokuGame extends StatefulWidget {
  @override
  _SudokuGameState createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  List<List<int>> grid = [];
  List<List<bool>> fixedCells = [];
  int selectedRow = -1;
  int selectedCol = -1;
  int score = 0;
  String difficulty = "Easy";

  @override
  void initState() {
    super.initState();
    generateNewGame(difficulty);
  }

  void generateNewGame(String difficulty) {
    setState(() {
      grid = List.generate(9, (i) => List.generate(9, (j) => 0));
      fixedCells = List.generate(9, (i) => List.generate(9, (j) => false));
      fillSudokuGrid();
      removeNumbersBasedOnDifficulty(difficulty);
    });
  }

  void fillSudokuGrid() {
    // Simple backtracking algorithm to fill the grid
    void solve(int row, int col) {
      if (row == 9) return;
      if (col == 9) {
        solve(row + 1, 0);
        return;
      }
      List<int> nums = List.generate(9, (i) => i + 1)..shuffle();
      for (int num in nums) {
        if (isValidMove(row, col, num)) {
          grid[row][col] = num;
          solve(row, col + 1);
          if (grid[8][8] != 0) return;
          grid[row][col] = 0;
        }
      }
    }
    solve(0, 0);
  }

  void removeNumbersBasedOnDifficulty(String difficulty) {
    int clues = difficulty == "Easy" ? 40 : difficulty == "Medium" ? 30 : 20;
    Random random = Random();
    for (int i = 0; i < 81 - clues; i++) {
      int row = random.nextInt(9);
      int col = random.nextInt(9);
      while (grid[row][col] == 0) {
        row = random.nextInt(9);
        col = random.nextInt(9);
      }
      grid[row][col] = 0;
      fixedCells[row][col] = false;
    }
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] != 0) fixedCells[row][col] = true;
      }
    }
  }

  bool isValidMove(int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == num || grid[i][col] == num) return false;
    }
    int blockRowStart = (row ~/ 3) * 3;
    int blockColStart = (col ~/ 3) * 3;
    for (int i = blockRowStart; i < blockRowStart + 3; i++) {
      for (int j = blockColStart; j < blockColStart + 3; j++) {
        if (grid[i][j] == num) return false;
      }
    }
    return true;
  }

  void handleNumberInput(int num) {
    if (selectedRow != -1 && selectedCol != -1 && !fixedCells[selectedRow][selectedCol]) {
      if (isValidMove(selectedRow, selectedCol, num)) {
        setState(() {
          grid[selectedRow][selectedCol] = num;
          score += 10;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid Move! -5 points')),
        );
        setState(() {
          score = max(0, score - 5);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:Colors.white,
        title: Text('Sudoku - $difficulty Mode', style: const TextStyle(color: Colors.black)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                difficulty = value;
                generateNewGame(difficulty);
              });
            },
            itemBuilder: (BuildContext context) {
              return ["Easy", "Medium", "Hard"].map((String choice) {
                return PopupMenuItem<String>(

                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 500,
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                int row = index ~/ 9;
                int col = index % 9;
                int num = grid[row][col];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRow = row;
                      selectedCol = col;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: (selectedRow == row && selectedCol == col)
                          ? Colors.lightBlueAccent
                          : fixedCells[row][col]
                              ? Colors.grey[300]
                              : null,
                    ),
                    child: Text(
                      num != 0 ? num.toString() : '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: fixedCells[row][col]
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 1; i <= 9; i++)
                  TextButton(
                    onPressed: () => handleNumberInput(i),
                    child: Text(i.toString(),
                        style: const TextStyle(fontSize: 20)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Score: $score', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
