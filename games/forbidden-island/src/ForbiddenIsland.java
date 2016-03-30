// Assignment 9
// Lisa Chan
// lisachannn
// Junhao Dong
// junhao

import java.util.ArrayList;
import java.util.Random;
import tester.*;
import javalib.impworld.*;
import java.awt.Color;
import javalib.worldimages.*;

interface IList<T> {
}

class Empty<T> implements IList<T> {
    // appends the given ArrayList of ArrayList values to this list
    IList<T> appendToList(ArrayList<ArrayList<T>> list) {
        IList<T> l = this;
        for (int i = 0; i < list.size(); i++) {
            ArrayList<T> row = list.get(i);
            
            for (int j = 0; j < row.size(); j++) {
                l = new Cons<T>(row.get(j), l);
            }
        }
        return l;
    }
}

class Cons<T> implements IList<T> {
    T first;
    IList<T> rest;
    
    Cons(T first, IList<T> rest) {
        this.first = first;
        this.rest = rest;
    }
}

// represents a single square of the game area
class Cell {
    // in logical coordinates, with the origin at the top-left corner of the scren
    int x;
    int y;
    // represents absolute height of this cell, in feet
    double height;
    // the four adjacent cells to this one
    Cell left;
    Cell top;
    Cell right;
    Cell bottom;
    // is this cell flooded or not
    boolean isFlooded;

    Cell(int x, int y, double height) {
        this.x = x;
        this.y = y;
        this.height = height;
        this.left = this;
        this.top = this;
        this.right = this;
        this.bottom = this;
        this.isFlooded = false;
    }
    Cell(int x, int y, double height,
         Cell left, Cell top, Cell right, Cell bottom) {
        this(x, y, height);
        this.left = left;
        this.top = top;
        this.right = right;
        this.bottom = bottom;
    }
}

// represents a single square of the ocean
class OceanCell extends Cell {
    OceanCell(int x, int y, double height) {
        super(x, y, height);
        this.isFlooded = true;
    }
    OceanCell(int x, int y, double height,
              Cell left, Cell top, Cell right, Cell bottom) {
        super(x, y, height, left, top, right, bottom);
        this.isFlooded = true;
    }
}
 
class ForbiddenIslandWorld extends World {
    // width of the island scene
    static final int ISLAND_WIDTH = 64;
    // height of the island scene
    static final int ISLAND_HEIGHT = 64;
    // the highest height of the island
    static final int maxHeight = 64;

    // all the cells of the game
    IList<Cell> board;
    // the current height of the ocean
    int waterHeight;

    ForbiddenIslandWorld() {
        this.board = this.createRegularMountain();
        this.waterHeight = 0;
    }

    // returns the scene to be shown on each tick
    public WorldScene makeScene() {
        return this.getEmptyScene();
    }

    // converts 2D lists of heights to 2D lists of cells
    ArrayList<ArrayList<Cell>> heightToCell(ArrayList<ArrayList<Double>>
                                            heights) {
        ArrayList<ArrayList<Cell>> cells = new ArrayList<ArrayList<Cell>>(heights.size());
        
        for (int i = 0; i < heights.size(); i++) {
            ArrayList<Double> row = heights.get(i);
            cells.add(new ArrayList<Cell>(row.size()));

            for (int j = 0; j < row.size(); j++) {
                double height = row.get(j);
                Cell current = cells.get(i).get(j);
                Cell left = cells.get(i).get(j - 1);
                Cell top = cells.get(i - 1).get(j);
                Cell right = cells.get(i).get(j + 1);
                Cell bottom = cells.get(i + 1).get(j);

                if (j == 0) {
                    left = current;
                }
                if (i == 0) {
                    top = current;
                }
                if (j == this.ISLAND_WIDTH) {
                    right = current;
                }
                if (i == this.ISLAND_HEIGHT) {
                    bottom = current;
                }

                if (height <= 0) {
                    cells.get(i).add(new OceanCell(j, i, height,
                                                   left, top, right, bottom));
                }
                else {
                    cells.get(i).add(new Cell(j, i, height,
                                              left, top, right, bottom));
                }
            }
        }
        return cells;
    }

    // returns a board of cells for a perfect regular mountain
    // the height of a cell is the max height minus its 
    // Manhattan distance from the center of the board
    IList<Cell> createRegularMountain() {
        ArrayList<ArrayList<Double>> heights;
        heights = new ArrayList<ArrayList<Double>>(this.ISLAND_HEIGHT + 1);

        for (int i = 0; i < this.ISLAND_HEIGHT + 1; i++) {
            heights.add(new ArrayList<Double>(this.ISLAND_WIDTH + 1));
            
            for (int j = 0; j < this.ISLAND_WIDTH + 1; j++) {
                double centerX = this.ISLAND_WIDTH / 2;
                double centerY = this.ISLAND_HEIGHT / 2;
                heights.get(i).add(this.maxHeight
                                   - Math.abs(j - centerX)
                                   - Math.abs(i - centerY));
            }
        }
        ArrayList<ArrayList<Cell>> cells = this.heightToCell(heights);
        IList<Cell> board = new Empty<Cell>().appendToList(cells);
        return board;
    }

    // returns a board of cells for a random height diamond mountain
    // the height of a cell is the max height minus its 
    // Manhattan distance from the center of the board
    IList<Cell> createRandomMountain() {
        ArrayList<ArrayList<Double>> heights;
        heights = new ArrayList<ArrayList<Double>>(this.ISLAND_HEIGHT + 1);

        Random rand = new Random();
        double centerX;
        double centerY;
        double distance;
        for (int i = 0; i < this.ISLAND_HEIGHT + 1; i++) {
            heights.add(new ArrayList<Double>(this.ISLAND_WIDTH + 1));
            
            for (int j = 0; j < this.ISLAND_WIDTH + 1; j++) {
                centerX = this.ISLAND_WIDTH / 2;
                centerY = this.ISLAND_HEIGHT / 2;
                distance = (this.maxHeight
                            - Math.abs(j - centerX)
                            - Math.abs(i - centerY));

                if (distance > 0) {
                    distance = 1 + rand.nextInt(this.maxHeight);
                }
                heights.get(i).add(distance);
            }
        }
        ArrayList<ArrayList<Cell>> cells = this.heightToCell(heights);
        IList<Cell> board = new Empty<Cell>().appendToList(cells);
        return board;
    }
}
