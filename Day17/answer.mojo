from math import min

@always_inline
fn get_digit(one_char: String) -> Int:
    # Returns -1 if not digit, otherwise returns the digit
    let cur_ord = ord(one_char)
    alias l_bound = ord('0')
    alias r_bound = ord('9')
    if cur_ord > r_bound or cur_ord < l_bound: 
        return -1
    return cur_ord - l_bound

struct Row[T: CollectionElement](CollectionElement):
    var data: DynamicVector[T]

    fn __init__(inout self):
        self.data = DynamicVector[T]()

    fn __copyinit__(inout self, existing: Self):
        self.data = existing.data

    fn __moveinit__(inout self, owned existing: Self):
        self.__copyinit__(existing)

    # why no work :'(
    fn __setitem__(inout self: Self, i: Int, owned value: T):
        self.data[i] = T 

    fn __getitem__(self: Self, i: Int) -> T:
        return self.data[i]

struct Deque[T: CollectionElement]:
    var b1: DynamicVector[T]
    var b2: DynamicVector[T] 

    fn __init__(inout self):
        self.b1 = DynamicVector[T]()
        self.b2 = DynamicVector[T]()

    fn push_back(inout self, owned value: T):
        self.b1.push_back(value)

    fn pop_front(inout self) -> T:
        if len(self.b2) == 0:
            while len(self.b1) > 0:
                self.b2.push_back(self.b1.pop_back())
        return self.b2.pop_back()

    fn size(inout self) -> Int:
        return len(self.b1) + len(self.b2)
    
alias MAX_INT = 200000000

# NOTE: +1 is 90 degree turn clockwise, -1 is counter-clockwise
alias LEFT = 0
alias UP = 1
alias RIGHT = 2
alias DOWN = 3

@always_inline
fn get_next_coord(prev: Tuple[Int, Int], dir: Int) -> Tuple[Int, Int]:
    let r = prev.get[0, Int]()
    let c = prev.get[1, Int]()

    if dir == LEFT:
        return (r, c - 1)
    if dir == UP:
        return (r - 1, c)
    if dir == RIGHT:
        return (r, c + 1)
    if dir == DOWN:
        return (r + 1, c)
    print('warning')
    return (-1, -1)

fn part1(grid: DynamicVector[Row[Int]]):
    let R = len(grid)
    let C = len(grid[0].data)

    @always_inline 
    fn get_flat_buffer_index(r: Int, c: Int, dir_cardinality: Int, n: Int) -> Int:
        return r * C * 2 * 3 + c * 2 * 3 + dir_cardinality * 3 + n

    # flattened version of buffer of shape [R][C][2][3]
    # where index [r][c][d][n], (r, c) are the corodinates
    # d is the cardinality of direction (vert or horz)
    # and n is the number of times moving in cur direction
    var flat_buffer_minimum = DynamicVector[Int](R * C * 2 * 3)
    for i in range(R * C * 2 * 3):
        flat_buffer_minimum[i] = MAX_INT

    # Tuple is (row, column, direction, number_of_times - 1, cur_heat)
    # cur_heat is before entering square, rest represents transition into square
    # TODO: bfs
    var queue = Deque[Tuple[Int, Int, Int, Int, Int]]()
    queue.push_back((1, 0, DOWN, 0, 0))
    queue.push_back((0, 1, RIGHT, 0, 0))

    while queue.size() > 0:
        let cur = queue.pop_front()

        let next_r = cur.get[0, Int]()
        let next_c = cur.get[1, Int]()
        let dir = cur.get[2, Int]()
        let next_n = cur.get[3, Int]()
        let prev_h = cur.get[4, Int]()
        if next_r < 0 or next_r >= R or next_c < 0 or next_c >= C:
            continue 
        if next_n >= 3:
            continue 

        let next_h = prev_h + grid[next_r][next_c]
        var all_good = True
        for other_n in range(3):
            if other_n > next_n:
                continue
            let flat_index = get_flat_buffer_index(next_r, next_c, dir % 2, other_n)
            all_good = all_good and (next_h < flat_buffer_minimum[flat_index])
        if not all_good:
            continue 
            
        # why no work :'(
        # flat_buffer_minimum[next_r][next_c][dir][next_n] = next_h
        let flat_index = get_flat_buffer_index(next_r, next_c, dir % 2, next_n)
        flat_buffer_minimum[flat_index] = next_h

        # case 1 continue forward!
        let forward = get_next_coord((next_r, next_c), dir)
        queue.push_back(
            (forward.get[0, Int](), forward.get[1, Int](), dir, next_n + 1, next_h)
        )

        # case 2 turn left!
        let turn_cw_dir = (dir + 1) % 4
        let turn_cw = get_next_coord((next_r, next_c), turn_cw_dir)
        queue.push_back(
            (turn_cw.get[0, Int](), turn_cw.get[1, Int](), turn_cw_dir, 0, next_h)
        )

        # case 3 turn left!
        let turn_ccw_dir = (dir + 3) % 4
        let turn_ccw = get_next_coord((next_r, next_c), turn_ccw_dir)
        queue.push_back(
            (turn_ccw.get[0, Int](), turn_ccw.get[1, Int](), turn_ccw_dir, 0, next_h)
        )

    var answer = MAX_INT
    for d in range(2):
        for n in range(3):
            answer = min(answer, flat_buffer_minimum[get_flat_buffer_index(R - 1, C - 1, d, n)])
    print("Part1:", answer)

fn part2(grid: DynamicVector[Row[Int]]):
    let R = len(grid)
    let C = len(grid[0].data)

    @always_inline 
    fn get_flat_buffer_index(r: Int, c: Int, dir: Int, n: Int) -> Int:
        if r < 0 or c < 0 or r >= R or c >= C or dir < 0 or dir > 4 or n < 0 or n >= 10:
            return -1
        return r * C * 4 * 10 + c * 4 * 10 + dir * 10 + n

    # flattened version of buffer of shape [R][C][2][10]
    # where index [r][c][d][n], (r, c) are the corodinates
    # d is the cardinality of direction (vert or horz)
    # and n is the number of times moving in cur direction
    var flat_buffer_minimum = DynamicVector[Int](R * C * 4 * 10)
    for i in range(R * C * 4 * 10):
        flat_buffer_minimum[i] = MAX_INT

    # Tuple is (row, column, direction, number_of_times - 1, cur_heat)
    # cur_heat is before entering square, rest represents transition into square
    # TODO: bfs
    var queue = Deque[Tuple[Int, Int, Int, Int, Int]]()
    queue.push_back((1, 0, DOWN, 0, 0))
    queue.push_back((0, 1, RIGHT, 0, 0))

    while queue.size() > 0:
        let cur = queue.pop_front()

        let next_r = cur.get[0, Int]()
        let next_c = cur.get[1, Int]()
        let dir = cur.get[2, Int]()
        let next_n = cur.get[3, Int]()
        let prev_h = cur.get[4, Int]()
        let flat_index = get_flat_buffer_index(next_r, next_c, dir, next_n)
        if flat_index < 0:
            continue

        # might be slightly wrong
        let next_h = prev_h + grid[next_r][next_c]
        if next_h >= flat_buffer_minimum[flat_index]:
            continue
            
        flat_buffer_minimum[flat_index] = next_h

        # case 1 continue forward!
        let forward = get_next_coord((next_r, next_c), dir)
        queue.push_back(
            (forward.get[0, Int](), forward.get[1, Int](), dir, next_n + 1, next_h)
        )

        # case 2 turn left!
        if next_n >= 3:
            let turn_cw_dir = (dir + 1) % 4
            let turn_cw = get_next_coord((next_r, next_c), turn_cw_dir)
            queue.push_back(
                (turn_cw.get[0, Int](), turn_cw.get[1, Int](), turn_cw_dir, 0, next_h)
            )

            # case 3 turn left!
            let turn_ccw_dir = (dir + 3) % 4
            let turn_ccw = get_next_coord((next_r, next_c), turn_ccw_dir)
            queue.push_back(
                (turn_ccw.get[0, Int](), turn_ccw.get[1, Int](), turn_ccw_dir, 0, next_h)
            )

    var answer = MAX_INT
    for d in range(4):
        for n in range(3, 10):
            answer = min(answer, flat_buffer_minimum[get_flat_buffer_index(R - 1, C - 1, d, n)])
    print("Part1:", answer)


fn main() raises:
    # NOTE: Does not work due to bu in dynamic vector?
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        let patterns = lines.split("\n")
        
        var grid = DynamicVector[Row[Int]]()
        for i in range(len(patterns)):
            let cur = patterns[i]
            var cur_row = Row[Int]()
            for j in range(len(cur)):
                cur_row.data.push_back(get_digit(cur[j]))
            grid.push_back(cur_row ^)

        part1(grid)
        part2(grid)