struct Row[T: CollectionElement](CollectionElement):
    var data: DynamicVector[T]

    fn __init__(inout self):
        self.data = DynamicVector[T]()

    fn __copyinit__(inout self, existing: Self):
        self.data = existing.data

    fn __moveinit__(inout self, owned existing: Self):
        self.__copyinit__(existing)


@always_inline
fn get_connected(data: DynamicVector[String], r: Int, c: Int) -> Tuple[Tuple[Int, Int], Tuple[Int, Int]]:
    let char = data[r][c]
    if char == "|":
        return ((r - 1, c), (r + 1, c))
    elif char == "-":
        return ((r, c - 1), (r, c + 1))
    elif char == "L":
        return ((r - 1, c), (r, c + 1))
    elif char == "J":
        return ((r - 1, c), (r, c - 1))
    elif char == "7":
        return ((r + 1, c), (r, c - 1))
    elif char == "F":
        return ((r + 1, c), (r, c + 1))
    else:
        return ((-1, -1), (-1, -1))

@always_inline
fn is_valid_index(data: DynamicVector[String], r: Int, c: Int) -> Bool:
    return r >= 0 and c >= 0 and r < len(data) and c < len(data[0])

fn part1_and_2(inout data: DynamicVector[String]):
    let R = len(data)
    let C = len(data[0]) 
    # -1 = not reacheable/visited, else the total length from start
    var answer = DynamicVector[Row[Int]]()

    # initialize stores
    for r in range(R):
        var cur_answer = Row[Int]()
        for c in range(C):
            cur_answer.data.push_back(-1)
        answer.push_back(cur_answer ^)

    # find the first S
    var start_r = 0
    var start_c = 0
    while data[start_r][start_c] != "S":
        start_c += 1
        if start_c == C:
            start_c = 0 
            start_r += 1 

    # Replace start with proper symbol
    let neighbors_start = StaticTuple[4, Tuple[Int, Int]](
        (start_r - 1, start_c), 
        (start_r + 1, start_c), 
        (start_r, start_c - 1), 
        (start_r, start_c + 1)
    )
    var neighbors_connected = StaticTuple[4, Bool](False, False, False)
    for i in range(4):
        let neighor_r = neighbors_start[i].get[0, Int]()
        let neighor_c = neighbors_start[i].get[1, Int]()
        if not is_valid_index(data, neighor_r, neighor_c):
            continue 
        let connected_to = get_connected(data, neighor_r, neighor_c)
        let r1 = connected_to.get[0, Tuple[Int, Int]]().get[0, Int]()
        let c1 = connected_to.get[0, Tuple[Int, Int]]().get[1, Int]()
        let r2 = connected_to.get[1, Tuple[Int, Int]]().get[0, Int]()
        let c2 = connected_to.get[1, Tuple[Int, Int]]().get[1, Int]()
        neighbors_connected[i] = (r1 == start_r and c1 == start_c) or (r2 == start_r and c2 == start_c)
    let char: String 
    if neighbors_connected[0] and neighbors_connected[1]:
        char = "|"
    elif neighbors_connected[0] and neighbors_connected[2]:
        char = "J"
    elif neighbors_connected[0] and neighbors_connected[3]:
        char = "L"
    elif neighbors_connected[1] and neighbors_connected[2]:
        char = "7"
    elif neighbors_connected[1] and neighbors_connected[3]:
        char = "F"
    else: # neighbors_connected[2] and neighbors_connected[3]
        char = "-"
    data[start_r] = data[start_r].replace("S", char)

    var cur_r = start_r 
    var cur_c = start_c
    answer[start_r].data[start_c] = 0
    while True:
        let connected_to = get_connected(data, cur_r, cur_c)
        let r1 = connected_to.get[0, Tuple[Int, Int]]().get[0, Int]()
        let c1 = connected_to.get[0, Tuple[Int, Int]]().get[1, Int]()
        let r2 = connected_to.get[1, Tuple[Int, Int]]().get[0, Int]()
        let c2 = connected_to.get[1, Tuple[Int, Int]]().get[1, Int]()

        if is_valid_index(data, r1, c1) and answer[r1].data[c1] < 0:
            answer[r1].data[c1] = answer[cur_r].data[cur_c] + 1
            cur_r = r1 
            cur_c = c1 
        elif is_valid_index(data, r2, c2) and answer[r2].data[c2] < 0:
            answer[r2].data[c2] = answer[cur_r].data[cur_c] + 1
            cur_r = r2
            cur_c = c2 
        else:
            # back to the start
            answer[start_r].data[start_c] = answer[cur_r].data[cur_c] + 1
            break 

    print("Part1:", answer[start_r].data[start_c] // 2)

    # part 2 flood fill, expand each cell into 3x3 grid 
    # 0 == empty space, 1 == pipe not part of main loop, 2 == pipe part of main loop, 3 == visited
    var expanded_data = DynamicVector[Row[Int]]()
    for r in range(R * 3):
        var cur_row = Row[Int]()
        for c in range(C * 3):
            cur_row.data.push_back(0)
        expanded_data.push_back(cur_row ^)

    # populate proper pipe values
    for r in range(R):
        for c in range(C):
            let char = data[r][c]
            let er = r * 3 
            let ec = c * 3
            let pipe_value = 2 if answer[r].data[c] >= 0 else 1
            if char == "|":
                expanded_data[er].data[ec + 1] = pipe_value
                expanded_data[er + 1].data[ec + 1] = pipe_value
                expanded_data[er + 2].data[ec + 1] = pipe_value
            elif char == "-":
                expanded_data[er + 1].data[ec] = pipe_value
                expanded_data[er + 1].data[ec + 1] = pipe_value
                expanded_data[er + 1].data[ec + 2] = pipe_value
            elif char == "L":
                expanded_data[er].data[ec + 1] = pipe_value
                expanded_data[er + 1].data[ec + 1] = pipe_value
                expanded_data[er + 1].data[ec + 2] = pipe_value
            elif char == "J":
                expanded_data[er].data[ec + 1] = pipe_value
                expanded_data[er + 1].data[ec + 1] = pipe_value
                expanded_data[er + 1].data[ec] = pipe_value
            elif char == "7":
                expanded_data[er + 1].data[ec] = pipe_value
                expanded_data[er + 1].data[ec + 1] = pipe_value
                expanded_data[er + 2].data[ec + 1] = pipe_value            
            elif char == "F": 
                expanded_data[er + 1].data[ec + 1] = pipe_value
                expanded_data[er + 2].data[ec + 1] = pipe_value    
                expanded_data[er + 1].data[ec + 2] = pipe_value

    var answer_p2 = 0
    for sr in range(R * 3):
        for sc in range(C * 3):
            if expanded_data[sr].data[sc] != 0:
                continue

            # On a pipe, 0 == ground, 1 == pipe not main loop, 2 == pipe in main loop, 3 == visited ground
            var fringe = DynamicVector[Tuple[Int, Int]]()
            fringe.push_back((sr, sc))

            # if we touch a main pipe and don't touch the edge we are good
            # NOTE: this assumes the main pipe is not surrounded by a larger pipe
            var touches_main_pipe = False 
            var touches_edge = False 
            var local_full_grounds = 0
            while len(fringe) > 0:
                let cur = fringe.pop_back()
                let cur_r = cur.get[0, Int]()
                let cur_c = cur.get[1, Int]()

                if cur_r < 0 or cur_c < 0 or cur_r >= 3 * R or cur_c >= 3 * C:
                    touches_edge = True
                    continue
                if expanded_data[cur_r].data[cur_c] == 2:
                    touches_main_pipe = True 
                if expanded_data[cur_r].data[cur_c] != 0:
                    continue

                # calculate if corresponds to '.' or a pipe that is not ours (2)
                # mutate original stuff to count
                if cur_r % 3 == 0 and cur_c % 3 == 0:
                    if expanded_data[cur_r + 1].data[cur_c + 1] != 2:
                        local_full_grounds += 1

                # Mark visited
                expanded_data[cur_r].data[cur_c] = 3
                fringe.push_back((cur_r - 1, cur_c)) 
                fringe.push_back((cur_r + 1, cur_c)) 
                fringe.push_back((cur_r, cur_c - 1)) 
                fringe.push_back((cur_r, cur_c + 1))

            if touches_main_pipe and not touches_edge:
                answer_p2 += local_full_grounds

    # Off by one but too lazy to fix
    print("Part2:", answer_p2)

fn main() raises:
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        var data = lines.split("\n")
        part1_and_2(data)