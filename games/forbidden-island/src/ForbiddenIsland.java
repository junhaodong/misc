// Assignment 9
// Lisa Chan
// lisachannn
// Junhao Dong
// junhao

import java.util.*;
import tester.*;
import javalib.impworld.*;
import java.awt.Color;
import javalib.worldimages.*;

// represents a list
interface IList<T> extends Iterable<T> {
    // is this object a Cons
    boolean isCons();
    // return this IList as a Cons
    Cons<T> asCons();
}

// represents an empty list
class Empty<T> implements IList<T> {
    Empty() {
        //empty
    }

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
    // return an iterator for this object
    public Iterator<T> iterator() {
        return new IListIterator<T>(this);
    }
    // is this object a Cons
    public boolean isCons() {
        return false;
    }
    // return this IList as a Cons
    public Cons<T> asCons() {
        throw new UnsupportedOperationException("Should never be called");
    }
}

// represents a non empty list
class Cons<T> implements IList<T> {
    T first;
    IList<T> rest;

    Cons(T first, IList<T> rest) {
        this.first = first;
        this.rest = rest;
    }

    // return an iterator for this object
    public Iterator<T> iterator() {
        return new IListIterator<T>(this);
    }
    // is this object a Cons
    public boolean isCons() {
        return true;
    }
    // return this IList as a Cons
    public Cons<T> asCons() {
        return this;
    }
}

// represents an iterator
class IListIterator<T> implements Iterator<T> {
    IList<T> items;

    IListIterator(IList<T> items) {
        this.items = items;
    }

    // does this sequence have at least one more value
    public boolean hasNext() {
        return this.items.isCons();
    }
    // get the next value in the sequence
    public T next() {
        Cons<T> itemsAsCons = this.items.asCons();
        T answer = itemsAsCons.first;
        this.items = itemsAsCons.rest;
        return answer;
    }
    // remove the item just returned by next(); currently unsupported
    public void remove() {
        throw new UnsupportedOperationException("Don't do this!");
    }
}

//represents a single square of the game area
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

    // updates the neighbors of this cell
    void updateNeighbors(Cell left, Cell top, Cell right, Cell bottom) {
        this.left = left;
        this.top = top;
        this.right = right;
        this.bottom = bottom;
    }

    // is this cell an ocean cell
    boolean isOcean() {
        return false;
    }
}

//represents a single square of the ocean
class OceanCell extends Cell {
    OceanCell(int x, int y, double height) {
        super(x, y, height);
        this.isFlooded = true;
    }

    // is this cell an ocean cell
    boolean isOcean() {
        return true;
    }
}

class ForbiddenIslandWorld extends World {
    // width of the island scene
    static final int ISLAND_WIDTH = 64;
    // height of the island scene
    static final int ISLAND_HEIGHT = 64;

    // all the cells of the game
    IList<Cell> board;
    // the current height of the ocean
    int waterHeight;
    // the highest height of the island
    int maxHeight;
    // scale for drawing images
    int scale;

    ForbiddenIslandWorld() {
        this.board = new Empty<Cell>();
        this.waterHeight = 0;
        this.maxHeight = 64; // will vary according to difficulty later
        this.scale = 10;
    }

    // returns the scene to be shown on each tick
    public WorldScene makeScene() {
        WorldScene scene = new WorldScene(ForbiddenIslandWorld.ISLAND_WIDTH * this.scale,
                ForbiddenIslandWorld.ISLAND_HEIGHT * this.scale);
        Color color;
        WorldImage rect;

        for (Cell cell : this.board) {
            if (cell.isOcean()) {
                color = Color.BLUE;
            }
            else if (cell.isFlooded) { // cellHeight + 1 <= waterHeight
                // blue to black as waterHeight - cellHeight increases
                color = new Color(0,
                        50,
                        255 * maxHeight / waterHeight);
            }
            else if (cell.height <= waterHeight) {
                // green to red as waterHeight - cellHeight increases
                color = new Color((int)(255 * (waterHeight - cell.height) / maxHeight),
                        (int)(255 - (255 * (waterHeight - cell.height) / maxHeight)),
                        0);
            }
            else {
                // green to white as cellHeight - waterHeight increases
                color = new Color((int)(255 * cell.height / maxHeight),
                        245,
                        (int)(255 * cell.height / maxHeight));
            }

            rect = new RectangleImage(this.scale, this.scale, "solid", color);

            scene.placeImageXY(rect, cell.x * this.scale, cell.y * this.scale);
        }
        return scene;
    }

    // updates the neighbors of each cell in the given list of list
    void updateNeighbors(ArrayList<ArrayList<Cell>> cells) {
        for (int i = 0; i < cells.size(); i++) {
            ArrayList<Cell> row = cells.get(i);
            for (int j = 0; j < row.size(); j++) {
                Cell current = cells.get(i).get(j);
                Cell left = current;
                Cell top = current;
                Cell right = current;
                Cell bottom = current;

                if (j != 0) {
                    left = cells.get(i).get(j - 1);
                }
                if (i != 0) {
                    top = cells.get(i - 1).get(j);
                }
                if (j != ForbiddenIslandWorld.ISLAND_WIDTH) {
                    right = cells.get(i).get(j + 1);
                }
                if (i != ForbiddenIslandWorld.ISLAND_HEIGHT) {
                    bottom = cells.get(i + 1).get(j);
                }
                current.updateNeighbors(left, top, right, bottom);
            }
        }
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

                if (height <= 0) {
                    cells.get(i).add(new OceanCell(j, i, height));
                }
                else {
                    cells.get(i).add(new Cell(j, i, height));
                }
            }
        }
        return cells;
    }

    // returns a board of cells for a perfect regular mountain
    // the height of a cell is the max height minus its 
    // Manhattan distance from the center of the board
    void initRegularMountain() {
        ArrayList<ArrayList<Double>> heights;
        heights = new ArrayList<ArrayList<Double>>(ForbiddenIslandWorld.ISLAND_HEIGHT + 1);

        double centerX;
        double centerY;
        double height;
        for (int i = 0; i < ForbiddenIslandWorld.ISLAND_HEIGHT + 1; i++) {
            heights.add(new ArrayList<Double>(ForbiddenIslandWorld.ISLAND_WIDTH + 1));

            for (int j = 0; j < ForbiddenIslandWorld.ISLAND_WIDTH + 1; j++) {
                centerX = ForbiddenIslandWorld.ISLAND_WIDTH / 2;
                centerY = ForbiddenIslandWorld.ISLAND_HEIGHT / 2;
                height = (this.maxHeight
                        - Math.abs(j - centerX)
                        - Math.abs(i - centerY));
                if (height > this.maxHeight / 2) {
                    heights.get(i).add(height);
                }
                else {
                    heights.get(i).add(0.0);
                }
            }
        }
        ArrayList<ArrayList<Cell>> cells = this.heightToCell(heights);
        this.updateNeighbors(cells);
        IList<Cell> board = new Empty<Cell>().appendToList(cells);
        this.board = board;
    }

    // returns a board of cells for a random height diamond mountain
    // the height of a cell is randomly generated
    void initRandomMountain() {
        ArrayList<ArrayList<Double>> heights;
        heights = new ArrayList<ArrayList<Double>>(ForbiddenIslandWorld.ISLAND_HEIGHT + 1);

        Random rand = new Random();
        double centerX;
        double centerY;
        double height;
        for (int i = 0; i < ForbiddenIslandWorld.ISLAND_HEIGHT + 1; i++) {
            heights.add(new ArrayList<Double>(ForbiddenIslandWorld.ISLAND_WIDTH + 1));

            for (int j = 0; j < ForbiddenIslandWorld.ISLAND_WIDTH + 1; j++) {
                centerX = ForbiddenIslandWorld.ISLAND_WIDTH / 2;
                centerY = ForbiddenIslandWorld.ISLAND_HEIGHT / 2;
                height = (this.maxHeight
                        - Math.abs(j - centerX)
                        - Math.abs(i - centerY));

                if (height > this.maxHeight / 2) {
                    height = 1 + rand.nextInt(this.maxHeight);
                }
                else {
                    height = 0;
                }
                heights.get(i).add(height);
            }
        }
        ArrayList<ArrayList<Cell>> cells = this.heightToCell(heights);
        this.updateNeighbors(cells);
        IList<Cell> board = new Empty<Cell>().appendToList(cells);
        this.board = board;
    }
}

// example class for forbidden island
class ExamplesForbiddenIsland {
    IList<String> empty = new Empty<String>();
    IList<String> cons1 = new Cons<String>("a", empty);
    IList<String> cons2 = new Cons<String>("b", cons1);

    ForbiddenIslandWorld fw;

    ArrayList<ArrayList<Double>> heights;
    ArrayList<ArrayList<Cell>> heightsCell;
    IList<Cell> heightsList;

    ArrayList<ArrayList<Cell>> regularCell;
    IList<Cell> regularList;
    ArrayList<ArrayList<Cell>> randomCell;

    ArrayList<Double> h1;
    ArrayList<Double> h2;
    ArrayList<ArrayList<Double>> h;


    Cell c00;
    Cell c10;
    Cell c20;
    Cell c01;
    Cell c11;
    Cell c21;
    ArrayList<Cell> c0;
    ArrayList<Cell> c1;
    ArrayList<ArrayList<Cell>> c;
    IList<Cell> cList;

    Cell ce00;
    Cell ce10;
    Cell ce20;
    Cell ce01;
    Cell ce11;
    Cell ce21;
    ArrayList<Cell> ce0;
    ArrayList<Cell> ce1;
    ArrayList<ArrayList<Cell>> ce;
    IList<Cell> ceList;

    // initializes the data
    void initData() {
        fw = new ForbiddenIslandWorld();

        heights = new ArrayList<ArrayList<Double>>(64);
        // sets heights to lists of doubles representing heights on the columns 
        // of the board for board width 64
        for (int i = 0; i < 64; i++) {
            ArrayList<Double> colh = new ArrayList<Double>(64);
            for (int j = 0; j < 64; j++) {
                colh.add(i * 64.0 + j + 1);
            }
            heights.add(colh);
        }

        heightsCell = new ArrayList<ArrayList<Cell>>(64);
        // sets arguments from heights to cells of heightsCell respectively
        // for board width 64
        for (int i = 0; i < 64; i++) {
            ArrayList<Cell> colc = new ArrayList<Cell>(64);
            for (int j = 0; j < 64; j++) {
                colc.add(new Cell(j, i, heights.get(i).get(j)));
            }
            heightsCell.add(colc);
        }

        ArrayList<ArrayList<Double>> regularDouble = 
                new ArrayList<ArrayList<Double>>(65);
        // sets heights from regular mountain algorithm to the lists respectively
        // for board width 65
        for (int i = 0; i < 65; i++) {
            regularDouble.add(new ArrayList<Double>(65));
            for (int j = 0; j < 65; j++) {
                double height = 4096 - Math.abs(j - 32.0) - Math.abs(i - 32.0);
                if (height > 32) {
                    regularDouble.get(i).add(height);
                }
                else {
                    heights.get(i).add(0.0);
                }
            }
        }

        regularCell = fw.heightToCell(regularDouble);

        h1 = new ArrayList<Double>(Arrays.asList(0.0, .5, 1.0));
        h2 = new ArrayList<Double>(Arrays.asList(2.0, 0.0, -3.0));
        h = new ArrayList<ArrayList<Double>>(2);
        this.h.add(h1);
        this.h.add(h2);

        c00 = new OceanCell(0, 0, 0.0);
        c10 = new Cell(1, 0, 0.5);
        c20 = new Cell(2, 0, 1.0);
        c01 = new Cell(0, 1, 2.0);
        c11 = new OceanCell(1, 1, 0.0);
        c21 = new OceanCell(2, 1, -3.0);
        c0 = new ArrayList<Cell>(3);
        c0.add(c00);
        c0.add(c10);
        c0.add(c20);
        c1 = new ArrayList<Cell>(3);
        c1.add(c01);
        c1.add(c11);
        c1.add(c21);
        c = new ArrayList<ArrayList<Cell>>(2);
        c.add(c0);
        c.add(c1);
        cList = new Cons<Cell>(c21, new Cons<Cell>(c11, new Cons<Cell>(c01,
                new Cons<Cell>(c20, new Cons<Cell>(c10, new Cons<Cell>(c00, 
                        new Empty<Cell>()))))));

        ce00 = new OceanCell(0, 0, 0.0);
        ce10 = new Cell(1, 0, 0.5);
        ce20 = new Cell(2, 0, 1.0);
        ce01 = new Cell(0, 1, 2.0);
        ce11 = new OceanCell(1, 1, 0.0);
        ce21 = new OceanCell(2, 1, -3.0);

        // first row
        ce00.left = ce00;
        ce00.top = ce00;
        ce00.right = ce10;
        ce00.bottom = ce01;
        ce10.left = ce00;
        ce10.top = ce10;
        ce10.right = ce20;
        ce10.bottom = ce11;
        ce20.left = ce10;
        ce20.top = ce20;
        ce20.right = ce20;
        ce20.bottom = ce21;
        //second row
        ce01.left = ce01;
        ce01.top = ce00;
        ce01.right = ce11;
        ce01.bottom = ce01;
        ce11.left = ce21;
        ce11.top = ce10;
        ce11.right = ce21;
        ce11.bottom = ce11;
        ce21.left = ce11;
        ce21.top = ce20;
        ce21.right = ce21;
        ce21.bottom = ce21;

        ce0 = new ArrayList<Cell>(Arrays.asList(ce00, ce10, ce20));
        ce1 = new ArrayList<Cell>(Arrays.asList(ce01, ce11, ce21));
        ce = new ArrayList<ArrayList<Cell>>(2);
        ce.add(ce0);
        ce.add(ce1);
        ceList = new Cons<Cell>(ce21, new Cons<Cell>(ce11, new Cons<Cell>(ce01, 
                new Cons<Cell>(ce20, new Cons<Cell>(ce10, new Cons<Cell>(ce00, 
                        new Empty<Cell>()))))));
    }

    // test for updateNeighbors
    void testUpdateNeighbors(Tester t) {
        initData();
        t.checkExpect(c00.left, c00);
        c00.updateNeighbors(ce00, ce00, ce10, ce01);
        t.checkExpect(c00, ce00);
        t.checkExpect(c00.left, ce00);
        t.checkExpect(c00.top, ce00);
        t.checkExpect(c00.right, ce10);
        t.checkExpect(c00.bottom, ce01);

        t.checkExpect(c01.bottom, c01);
        c01.updateNeighbors(ce01, ce00, ce11, ce01);
        t.checkExpect(c01, ce01);
        t.checkExpect(c01.left, ce01);
        t.checkExpect(c01.top, ce00);
        t.checkExpect(c01.right, ce11);
        t.checkExpect(c01.bottom, ce01);

        t.checkExpect(c21.top, c21);
        c21.updateNeighbors(ce11, ce20, ce21, ce21);
        t.checkExpect(c21, ce21);
        t.checkExpect(c21.left, ce11);
        t.checkExpect(c21.top, ce20);
        t.checkExpect(c21.right, ce21);
        t.checkExpect(c21.bottom, ce21);
    }

    // test for heightToCell
    void testHeightToCell(Tester t) {
        initData();
        t.checkExpect(fw.heightToCell(heights), heightsCell);
        t.checkExpect(fw.heightToCell(h), c);
    }

    // test for makeScene method
    void testMakeScene(Tester t) {
        initData();
        t.checkExpect(fw.makeScene().width, 640);
        t.checkExpect(fw.makeScene().height, 640);
    }

    // test for initRegularMountain method
    void testInitRegularMountain(Tester t) {
        initData();
        t.checkExpect(fw.board, new Empty<Cell>());
        fw.board = heightsList;

        fw.initRegularMountain();
        fw.updateNeighbors(regularCell);
        for (ArrayList<Cell> ac : regularCell)  {
            for (Cell c : ac) {
                t.checkRange(c.height, 0.0, 4097.0);
            }
        }
    }

    // test for appendToList method
    void testAppendToList(Tester t) {
        initData();
        t.checkExpect(new Empty<Cell>().appendToList(c), cList);
        t.checkExpect(new Empty<Cell>().appendToList(ce), ceList);
    }

    // test for isCons method
    void testIsCons(Tester t) {
        t.checkExpect(empty.isCons(), false);
        t.checkExpect(cons1.isCons(), true);
        t.checkExpect(cons2.isCons(), true);
    }

    // test for asCons method
    void testAsCons(Tester t) {
        t.checkException(new UnsupportedOperationException(
                "Should never be called"), empty, "asCons");
        t.checkExpect(cons1.asCons(), cons1);
        t.checkExpect(cons2.asCons(), cons2);
    }

    // test to display the regular mountain
    void testWorld(Tester t) {
        ForbiddenIslandWorld world = new ForbiddenIslandWorld();
        world.initRegularMountain();
        world.bigBang(world.scale * ForbiddenIslandWorld.ISLAND_WIDTH,
                      world.scale * ForbiddenIslandWorld.ISLAND_HEIGHT,
                      0);
    }

    // test to display the random mountain
    void testWorld2(Tester t) {
        ForbiddenIslandWorld world = new ForbiddenIslandWorld();
        world.initRandomMountain();
        world.bigBang(world.scale * ForbiddenIslandWorld.ISLAND_WIDTH,
                      world.scale * ForbiddenIslandWorld.ISLAND_HEIGHT,
                      0);
    }
}
