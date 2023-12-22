let G = 0 # '.'
let R = 1 # 'O'
let B = 2 # '#'

struct Grid(CollectionElement):
    var flat_buffer: DynamicVector[Int]
    var R: Int 
    var C: Int 

    fn __init__(inout self, rows: DynamicVector[String]):
        self.flat_buffer = DynamicVector[Int]()
        self.R = len(rows)
        self.C = len(rows[0])

        for r in range(self.R):
            for c in range(self.C):
                if rows[r][c] == ".":
                    self.flat_buffer.push_back(G) 
                elif rows[r][c] == "O":
                    self.flat_buffer.push_back(R) 
                else: # "#"
                    self.flat_buffer.push_back(B) 

    fn __copyinit__(inout self, existing: Self):
        self.flat_buffer = existing.flat_buffer
        self.R = existing.R
        self.C = existing.C

    fn __moveinit__(inout self, owned existing: Self):
        self.flat_buffer = existing.flat_buffer ^
        self.R = existing.R
        self.C = existing.C

    fn get_flat_buffer_index(self, r: Int, c: Int) -> Int:
        let answer = r * self.C + c
        return answer 

    fn get(self, r: Int, c: Int) -> Int:
        return self.flat_buffer[self.get_flat_buffer_index(r, c)] 

    fn swap(inout self, r1: Int, c1: Int, r2: Int, c2: Int):
        let i1 = self.get_flat_buffer_index(r1, c1)
        let i2 = self.get_flat_buffer_index(r2, c2)
        let tmp = self.flat_buffer[i1]
        self.flat_buffer[i1] = self.flat_buffer[i2]
        self.flat_buffer[i2] = tmp 

    fn equals(self, other: Grid) -> Bool:
        if len(self.flat_buffer) != len(other.flat_buffer):
            return False 
        for i in range(len(self.flat_buffer)):
            if self.flat_buffer[i] != other.flat_buffer[i]:
                return False 
        return True

    fn hash(self, other: Grid) -> Int:
        var hash = 7229
        for i in range(len(self.flat_buffer)):
            hash = (hash << 5) + hash + self.flat_buffer[i]
        return hash 

# if not reverse go north
fn roll_vert[reverse: Bool = False](inout grid: Grid):
    for c in range(grid.C):
        var furthest_r_ground = -1
        for dr in range(grid.R):
            let r: Int
            if reverse:
                r = grid.R - 1 - dr 
            else:
                r = dr

            let cur = grid.get(r, c)
            if cur == G:
                if furthest_r_ground == -1:
                    furthest_r_ground = r 
            elif cur == B:
                furthest_r_ground = -1
            else: # R == "O"
                if furthest_r_ground != -1:
                    grid.swap(r, c, furthest_r_ground, c)

                    if reverse:
                        furthest_r_ground -= 1
                    else:
                        furthest_r_ground += 1

# if not reverse go east
fn roll_horz[reverse: Bool = False](inout grid: Grid):
    for r in range(grid.R):
        var furthest_c_ground = -1
        for dc in range(grid.C):
            let c: Int
            if reverse:
                c = dc 
            else:
                c = grid.C - 1 - dc 

            let cur = grid.get(r, c)
            if cur == G:
                if furthest_c_ground == -1:
                    furthest_c_ground = c 
            elif cur == B:
                furthest_c_ground = -1
            else: # R == "O"
                if furthest_c_ground != -1:
                    grid.swap(r, c, r, furthest_c_ground)

                    if reverse:
                        furthest_c_ground += 1
                    else:
                        furthest_c_ground -= 1

fn print_grid(grid: Grid):
    for r in range(grid.R):
        var s = String()
        for c in range(grid.C):
            s += grid.get(r, c)
        print(s)

fn run_cycle(inout grid: Grid):
    # NWSE
    roll_vert(grid)
    roll_horz[True](grid)
    roll_vert[True](grid)
    roll_horz(grid)

fn calculate_load(inout grid: Grid) -> Int:
    var answer = 0
    for r in range(grid.R):
        for c in range(grid.C):
            if grid.get(r, c) == R:
                answer += (grid.R - r)
    return answer 

fn part1(inout grid: Grid):
    roll_vert(grid)
    print("Part1:", calculate_load(grid))

let N = 1000000000
fn part2(inout grid: Grid):
    fn get_cycle(inout grid: Grid) -> Tuple[Int, Int]:
        var cache = DynamicVector[Grid]()
        for i in range(N):
            # lol, i dont want to make a hash map and suspect the cycle length < 2000
            for j in range(len(cache)):
                if grid.equals(cache[j]):
                    return (j, i)
            cache.push_back(grid)
            run_cycle(grid)
        return (-1, -1)

    let info = get_cycle(grid)
    let start_index = info.get[0, Int]()
    let next_index = info.get[1, Int]()
    let cycle_length = next_index - start_index 

    var cur_cycle = (N - start_index) // (cycle_length) * cycle_length + start_index
    while cur_cycle < N:
        cur_cycle += 1
        run_cycle(grid)

    print("Part2:", calculate_load(grid))

fn main() raises:
    # NOTE: Does not work due to bu in dynamic vector?
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        let rows = lines.split("\n")
        
        var grid_p1 = Grid(rows)
        part1(grid_p1)

        var grid_p2 = Grid(rows)
        part2(grid_p2)