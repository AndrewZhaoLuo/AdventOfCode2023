from math import max 

let RIGHT = 0
let DOWN = 1
let LEFT = 2
let UP = 3

fn part1(grid: DynamicVector[String], start_rcd: Tuple[Int, Int, Int] = (0, 0, 0)) -> Int:
    let R = len(grid)
    let C = len(grid[0])

    # flat buffer of [R][C][D]
    # where index [r][c][d] is whether the tile has a beam
    # of cardinality d in it (see RIGHT, DOWN, LEFT, UP)
    var flat_buffer = DynamicVector[Int](R * C * 4)
    for i in range(R * C * 4):
        flat_buffer.push_back(0)

    fn get_flat_index(r: Int, c: Int, d: Int) -> Int:
        return r * C * 4 + c * 4 + d 

    # entries are r, c, d
    var fringe = DynamicVector[Tuple[Int, Int, Int]]()
    fringe.push_back(start_rcd)
    while len(fringe) > 0:
        let cur = fringe.pop_back()
        let r = cur.get[0, Int]()
        let c = cur.get[1, Int]()
        let d = cur.get[2, Int]()

        if r < 0 or r >= R or c < 0 or c >= C:
            continue 

        let flat_index = get_flat_index(r, c, d)
        if flat_buffer[flat_index]:
            continue 

        flat_buffer[flat_index] = 1

        if grid[r][c] == ".":
            if d == RIGHT:
                fringe.push_back((r, c + 1, d)) 
            elif d == DOWN:
                fringe.push_back((r + 1, c, d)) 
            elif d == LEFT:
                fringe.push_back((r, c - 1, d)) 
            elif d == UP:
                fringe.push_back((r - 1, c, d)) 
        elif grid[r][c] == "/":
            if d == RIGHT:
                fringe.push_back((r - 1, c, UP)) 
            elif d == DOWN:
                fringe.push_back((r, c - 1, LEFT)) 
            elif d == LEFT:
                fringe.push_back((r + 1, c, DOWN)) 
            elif d == UP:
                fringe.push_back((r, c + 1, RIGHT))         
        elif grid[r][c] == "\\":
            if d == RIGHT:
                fringe.push_back((r + 1, c, DOWN)) 
            elif d == DOWN:
                fringe.push_back((r, c + 1, RIGHT)) 
            elif d == LEFT:
                fringe.push_back((r - 1, c, UP)) 
            elif d == UP:
                fringe.push_back((r, c - 1, LEFT))     
        elif grid[r][c] == "-":
            if d == RIGHT:
                fringe.push_back((r, c + 1, RIGHT)) 
            elif d == DOWN:
                fringe.push_back((r, c + 1, RIGHT)) 
                fringe.push_back((r, c - 1, LEFT)) 
            elif d == LEFT:
                fringe.push_back((r, c - 1, LEFT)) 
            elif d == UP:
                fringe.push_back((r, c + 1, RIGHT)) 
                fringe.push_back((r, c - 1, LEFT))    
        elif grid[r][c] == "|":
            if d == RIGHT:
                fringe.push_back((r + 1, c, DOWN)) 
                fringe.push_back((r - 1, c, UP)) 
            elif d == DOWN:
                fringe.push_back((r + 1, c, DOWN)) 
            elif d == LEFT:
                fringe.push_back((r + 1, c, DOWN)) 
                fringe.push_back((r - 1, c, UP)) 
            elif d == UP:
                fringe.push_back((r - 1, c, UP))     
        else:
            print("WARNING!")

    var part1_answer = 0
    fn is_energized(r: Int, c: Int) -> Bool:
        for d in range(4):
            let flat_index = get_flat_index(r, c, d)
            if flat_buffer[flat_index]:
                return True 
        return False 

    for r in range(R):
        for c in range(C):
            if is_energized(r, c):
                part1_answer += 1

    return part1_answer

fn part2(grid: DynamicVector[String]) -> Int:
    var part2_answer = 0
    let R = len(grid)
    let C = len(grid[0])

    for r in range(R):
        let right_answer = part1(grid, (r, 0, RIGHT))
        let left_answer = part1(grid, (r, C - 1, LEFT))

        part2_answer = max(right_answer, part2_answer)
        part2_answer = max(left_answer, part2_answer)

    for c in range(C):
        let down_answer = part1(grid, (0, c, DOWN))
        let up_answer = part1(grid, (R - 1, c, UP))

        part2_answer = max(down_answer, part2_answer)
        part2_answer = max(up_answer, part2_answer)

    return part2_answer

fn main() raises:
    # NOTE: Does not work due to bu in dynamic vector?
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        let rows = lines.split("\n")        
        print("Part1:", part1(rows))
        print("Part2:", part2(rows))