from math import max, abs

let RIGHT = 0
let DOWN = 1
let LEFT = 2
let UP = 3

struct Instruction(CollectionElement):
    var direction: Int
    var number: Int 
    var color: String 

    fn __init__(inout self, direction: Int, number: Int, color: String):
        self.direction = direction
        self.number = number
        self.color = color

    fn __copyinit__(inout self, existing: Self):
        self.direction = existing.direction
        self.number = existing.number
        self.color = existing.color

    fn __moveinit__(inout self, owned existing: Self):
        self.direction = existing.direction
        self.number = existing.number
        self.color = existing.color ^

# right hand rule
# in quarter sections
fn get_corner_undercount(last_dir: Int, next_dir: Int) -> Int:
    if last_dir == RIGHT and next_dir == DOWN:
        return 3
    if last_dir == RIGHT and next_dir == UP:
        return 1
    if last_dir == DOWN and next_dir == RIGHT:
        return 1
    if last_dir == DOWN and next_dir == LEFT:
        return 3
    if last_dir == LEFT and next_dir == UP:
        return 3
    if last_dir == LEFT and next_dir == DOWN:
        return 1
    if last_dir == UP and next_dir == LEFT:
        return 1
    if last_dir == UP and next_dir == RIGHT:
        return 3
    print("WARNING")
    return 0


fn part1(instructions: DynamicVector[Instruction]) -> Int:
    var area = 0
    let N = len(instructions)

    # assume clockwise inputs
    var last_x = 0
    var last_y = 0
    var cur_x = 0
    var cur_y = 0
 
    var half_counts = 0
    var quarter_counts = 0

    for i in range(N):
        let cur_instruction = instructions[i]
        let direction = cur_instruction.direction
        let number = cur_instruction.number
        let color = cur_instruction.color

        # applying green's theorem, so must snap to edges of grid
        if direction == RIGHT:
            cur_x += number
        elif direction == DOWN:
            cur_y += number
        elif direction == LEFT:
            cur_x -= number
        else: # direction == UP
            cur_y -= number

        # green's theorem
        let local_area = (cur_y * last_x) - (cur_x * last_y) 
        area += local_area

        # un-snap to grid and account for half and quarter counts
        half_counts += (number - 1)

        let next_direction = instructions[(i + 1) % N].direction
        quarter_counts += get_corner_undercount(direction, next_direction)

        last_x = cur_x 
        last_y = cur_y

    return area // 2 + half_counts // 2 + quarter_counts // 4

fn hex_to_int(char: String) -> Int:
    if char == "0":
        return 0
    if char == "1":
        return 1
    if char == "2":
        return 2
    if char == "3":
        return 3
    if char == "4":
        return 4
    if char == "5":
        return 5
    if char == "6":
        return 6
    if char == "7":
        return 7
    if char == "8":
        return 8
    if char == "9":
        return 9
    if char == "a":
        return 10 
    if char == "b":
        return 11 
    if char == "c":
        return 12 
    if char == "d":
        return 13 
    if char == "e":
        return 14
    return 15 # char == "F"    

fn main() raises:
    # NOTE: Does not work due to bu in dynamic vector?
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        let rows = lines.split("\n")        
        var instructions_p1 = DynamicVector[Instruction]()
        for i in range(len(rows)):
            let splits = rows[i].split(" ")

            let direction: Int 
            if splits[0] == "R":
                direction = RIGHT 
            elif splits[0] == "D":
                direction = DOWN 
            elif splits[0] == "L":
                direction = LEFT
            else: # splits[0] == "U"
                direction = UP 

            let num = atol(splits[1])
            let color = splits[2][2:-1]
            instructions_p1.push_back(Instruction(direction, num, color^))

        print("Part1:", part1(instructions_p1))

        var instructions_p2 = DynamicVector[Instruction]()
        for i in range(len(rows)):
            let splits = rows[i].split(" ")
            let color = splits[2][2:-1]

            var number = 0
            for i in range(5):
                let digit = hex_to_int(color[i])
                number *= 16
                number += digit 

            let direction: Int 
            if color[5] == "0":
                direction = RIGHT 
            elif color[5] == "1":
                direction = DOWN 
            elif color[5] == "2":
                direction = LEFT 
            else:
                direction = UP 

            instructions_p2.push_back(Instruction(direction, number, color^))
        print("Part2:", part1(instructions_p2))
