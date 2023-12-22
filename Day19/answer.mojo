from math import min, max 

let PART_X = 0
let PART_M = 1
let PART_A = 2
let PART_S = 3
struct Part(CollectionElement):
    var data: StaticIntTuple[4]
    fn __init__(inout self, x: Int, m: Int, a: Int, s: Int):
        self.data = StaticIntTuple[4](x, m, a, s)
    fn __copyinit__(inout self, existing: Self):
        self.data = existing.data
    fn __moveinit__(inout self, owned existing: Self):
        self.__copyinit__(existing)

struct RangedPart(CollectionElement):
    var data: StaticTuple[4, Tuple[Int, Int]]
    fn __init__(inout self):
        self.data = StaticTuple[4, Tuple[Int, Int]](
            (1, 4000),
            (1, 4000),
            (1, 4000),
            (1, 4000)
        )
    fn __copyinit__(inout self, existing: Self):
        self.data = existing.data
    fn __moveinit__(inout self, owned existing: Self):
        self.__copyinit__(existing)

    fn range_ok(self, r: Tuple[Int, Int]) -> Bool:
        return r.get[0, Int]() <= r.get[1, Int]()

    fn is_possible(self) -> Bool:
        return self.range_ok(self.data[0]) and 
               self.range_ok(self.data[1]) and 
               self.range_ok(self.data[2]) and 
               self.range_ok(self.data[3])

fn component_to_index(component: String) -> Int:
    if component == "x":
        return PART_X
    elif component == 'm':
        return PART_M
    elif component == 'a':
        return PART_A
    else: # component == 's
        return PART_S 

# Treat as base 26 a == 0, b == 1, ... z == 25
fn name_to_index(name: String) -> Int:
    var index = 0
    for i in range(len(name)):
        let char = name[i]
        index *= 26
        index += ord(char) - ord('a')
    return index

# I love advent of parse 
let WORKFLOW_ACCEPT = -1
let WORKFLOW_REJECT = -2

let WORKFLOW_COMMAND_FAILURE = -3

let COMMAND_PASS = 0
let COMMAND_LT = 1
let COMMAND_GT = 2

# E.g. m>1548:A or A
struct Command(CollectionElement):
    var command_type: Int 
    var lhs_operand: Int 
    var rhs_number: Int 
    var next_workflow: Int 

    fn __init__(
        inout self, 
        command_type: Int, 
        lhs_operand: Int, 
        rhs_number: Int, 
        next_workflow: Int
    ):
        self.command_type = command_type
        self.lhs_operand = lhs_operand
        self.rhs_number = rhs_number
        self.next_workflow = next_workflow

    fn __copyinit__(inout self, existing: Self):
        self.command_type = existing.command_type
        self.lhs_operand = existing.lhs_operand
        self.rhs_number = existing.rhs_number
        self.next_workflow = existing.next_workflow

    fn __moveinit__(inout self, owned existing: Self):
        self.__copyinit__(existing)

    fn evaluate(self, part: Part) -> Int:
        if self.command_type == COMMAND_PASS:
            return self.next_workflow

        let lhs_number = part.data[self.lhs_operand]
        if self.command_type == COMMAND_LT:
            if lhs_number < self.rhs_number:
                return self.next_workflow
            else:
                return WORKFLOW_COMMAND_FAILURE
        else:
            if lhs_number > self.rhs_number:
                return self.next_workflow
            else:
                return WORKFLOW_COMMAND_FAILURE

    fn get_speculative_exec_true(self, part: RangedPart) -> RangedPart:
        if self.command_type == COMMAND_PASS:
            print("OH NAUER")
            return part

        let r = part.data[self.lhs_operand]
        let range_lo = r.get[0, Int]()
        let range_hi = r.get[1, Int]()

        var part_copy = part 
        if self.command_type == COMMAND_LT:
            part_copy.data[self.lhs_operand] = (range_lo, min(range_hi, self.rhs_number - 1))
        else:
            part_copy.data[self.lhs_operand] = (max(range_lo, self.rhs_number + 1), range_hi)
        return part_copy 

    fn get_speculative_exec_false(self, part: RangedPart) -> RangedPart:
        if self.command_type == COMMAND_PASS:
            print("OH NAUER")
            return part

        let r = part.data[self.lhs_operand]
        let range_lo = r.get[0, Int]()
        let range_hi = r.get[1, Int]()

        var part_copy = part 
        if self.command_type == COMMAND_LT:
            part_copy.data[self.lhs_operand] = (max(range_lo, self.rhs_number), range_hi)
        else:
            part_copy.data[self.lhs_operand] = (range_lo, min(range_hi, self.rhs_number))
        return part_copy 

struct Datum(CollectionElement):
    var part: RangedPart
    var index: Int 

    fn __init__(inout self, part: RangedPart, index: Int):
        self.part = part
        self.index = index
    fn __copyinit__(inout self, existing: Self):
        self.part = existing.part
        self.index = existing.index    
    fn __moveinit__(inout self, owned existing: Self):
        self.part = existing.part^
        self.index = existing.index

# E.g. "{a<2006:qkq,m>2090:A,rfg}"
struct Workflow(CollectionElement):
    var commands: DynamicVector[Command]
    fn __init__(inout self):
        self.commands = DynamicVector[Command]()
    fn __copyinit__(inout self, existing: Self):
        self.commands = existing.commands
    fn __moveinit__(inout self, owned existing: Self):
        self.commands = existing.commands ^

    fn run(self, part: Part) -> Int:
        for i in range(len(self.commands)):
            let cur_command = self.commands[i]
            let result = cur_command.evaluate(part)

            if result != WORKFLOW_COMMAND_FAILURE:
                return result 

        print("WARNING")
        return -1

    fn run_speculative(self, part: RangedPart) -> DynamicVector[Datum]:
        var answer = DynamicVector[Datum]()
        var cur_part = part 
        for i in range(len(self.commands)):
            let cur_command = self.commands[i]
            if cur_command.command_type == COMMAND_PASS:
                answer.push_back(Datum(cur_part, cur_command.next_workflow))
                continue 

            let true_part = cur_command.get_speculative_exec_true(cur_part)
            answer.push_back(Datum(true_part, cur_command.next_workflow))

            cur_part = cur_command.get_speculative_exec_false(cur_part)
        return answer

fn parse_command(command_string: String) raises -> Command:
    let split = command_string.split(":")

    if len(split) == 1:
        # not command, just go directly home
        if command_string == "A":
            return Command(COMMAND_PASS, -1, -1, WORKFLOW_ACCEPT) 
        if command_string == "R":
            return Command(COMMAND_PASS, -1, -1, WORKFLOW_REJECT) 
        return Command(COMMAND_PASS, -1, -1, name_to_index(command_string))

    let target_str = split[1]
    let target_int: Int 
    if target_str == "A":
        target_int = WORKFLOW_ACCEPT
    elif target_str == "R":
        target_int = WORKFLOW_REJECT
    else:
        target_int = name_to_index(target_str)

    let command_str = split[0]
    let lt_split = command_str.split('<')
    let gt_split = command_str.split('>')

    if len(lt_split) > 1:
        let index = component_to_index(lt_split[0]) 
        let number = atol(lt_split[1])
        return Command(COMMAND_LT, index, number, target_int)
    else:
        let index = component_to_index(gt_split[0]) 
        let number = atol(gt_split[1])
        return Command(COMMAND_GT, index, number, target_int)


fn parse_workflows(raw_string: String) raises -> DynamicVector[Workflow]:
    let max_workflow = name_to_index("zzz")
    var workflows = DynamicVector[Workflow](max_workflow + 1)
    for i in range(max_workflow + 1):
        workflows.push_back(Workflow())

    let workflow_strings = raw_string.split("\n")
    for i in range(len(workflow_strings)):
        let cur_workflow = workflow_strings[i]
        let cur_workflow_split = cur_workflow.split("{")
        let name = cur_workflow_split[0]
        let index = name_to_index(name)
        let command_strings = cur_workflow_split[1].split("}")[0].split(",")

        for j in range(len(command_strings)):
            let cur_command_string = command_strings[j]
            workflows[index].commands.push_back(parse_command(cur_command_string))

    return workflows

fn parse_parts(raw_string: String) raises -> DynamicVector[Part]:
    let part_strings = raw_string.split("\n")

    var answer = DynamicVector[Part]()

    for i in range(len(part_strings)):
        let part_string = part_strings[i]

        # entries are x=787 and the like
        let kwargs = part_string.split("{")[1].split("}")[0].split(",")
        let x = atol(kwargs[0].split("=")[1])
        let m = atol(kwargs[1].split("=")[1])
        let a = atol(kwargs[2].split("=")[1])
        let s = atol(kwargs[3].split("=")[1])
        answer.push_back(Part(x, m, a, s))
    return answer 

fn is_accepted(workflows: DynamicVector[Workflow], part: Part) -> Bool:
    var cur_workflow = name_to_index("in")
    while True:
        cur_workflow = workflows[cur_workflow].run(part)
        if (cur_workflow == WORKFLOW_ACCEPT):
            return True
        if cur_workflow == WORKFLOW_REJECT:
            return False 

fn part1(workflows: DynamicVector[Workflow], parts: DynamicVector[Part]):
    var answer = 0
    for i in range(len(parts)):
        if is_accepted(workflows, parts[i]):
            answer += parts[i].data[0]
            answer += parts[i].data[1]
            answer += parts[i].data[2]
            answer += parts[i].data[3]
    print("Part1:", answer)


fn part2(workflows: DynamicVector[Workflow]):
    var accepted = DynamicVector[RangedPart]()

    var fringe = DynamicVector[Datum]()
    fringe.push_back(Datum(RangedPart(), name_to_index("in")))

    while len(fringe) > 0:
        let cur = fringe.pop_back()
        let ranged_part = cur.part 
        let cur_index = cur.index

        if not ranged_part.is_possible():
            continue
        if cur_index == WORKFLOW_ACCEPT:
            accepted.push_back(ranged_part^)
            continue 
        elif cur_index == WORKFLOW_REJECT:
            continue
        else:
            let workflow = workflows[cur_index]
            let possibilities = workflow.run_speculative(ranged_part)
            for i in range(len(possibilities)):
                fringe.push_back(possibilities[i])
    
    var answer_p2 = 0
    for i in range(len(accepted)):
        let cur_part = accepted[i]

        var local_answer = 1
        for i in range(4):
            let r = (cur_part.data[i].get[1, Int]() - cur_part.data[i].get[0, Int]() + 1)
            local_answer *= r 
        answer_p2 += local_answer
    print("Part2:", answer_p2)

fn main() raises:
    # NOTE: Does not work due to bu in dynamic vector?
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        let splits = lines.split("\n\n")
        let workflows = parse_workflows(splits[0]) 
        let parts = parse_parts(splits[1])

        part1(workflows, parts)
        part2(workflows)