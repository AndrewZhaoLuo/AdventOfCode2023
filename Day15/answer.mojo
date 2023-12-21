
@always_inline
fn get_digit(one_char: String) -> Int:
    # Returns -1 if not digit, otherwise returns the digit
    let cur_ord = ord(one_char)
    alias l_bound = ord('0')
    alias r_bound = ord('9')
    if cur_ord > r_bound or cur_ord < l_bound: 
        return -1
    return cur_ord - l_bound

@always_inline 
fn part1_hash(s: String) -> Int:
    var answer = 0

    for i in range(len(s)):
        answer += ord(s[i])
        answer *= 17
        answer %= 256

    return answer 

fn part1(patterns: DynamicVector[String]) raises:
    var answer = 0
    for i in range(len(patterns)):
        answer += part1_hash(patterns[i])
    print("Part1:", answer)

struct Row[T: CollectionElement](CollectionElement):
    var data: DynamicVector[T]

    fn __init__(inout self):
        self.data = DynamicVector[T]()

    fn __copyinit__(inout self, existing: Self):
        self.data = existing.data

    fn __moveinit__(inout self, owned existing: Self):
        self.__copyinit__(existing)

struct Datum(CollectionElement):
    var key: String 
    var value: Int 

    fn __init__(inout self, key: String, value: Int):
        self.key = key 
        self.value = value

    fn __copyinit__(inout self, existing: Self):
        self.key = existing.key
        self.value = existing.value

    fn __moveinit__(inout self, owned existing: Self):
        self.__copyinit__(existing)
        self.key.__del__()

# pc-  ==> (pc, -1)
# pc=6 ==> (pc, 6)
@always_inline 
fn get_info(pattern: String) -> Datum:
    var key = String()
    var value = 0
    var i = 0
    while i < len(pattern):
        if pattern[i] == "=":
            break
        if pattern[i] == "-":
            return Datum(key ^, -1) 
        key += pattern[i]
        i += 1

    i += 1
    while i < len(pattern):
        value *= 10
        value += get_digit(pattern[i])
        i += 1

    return Datum(key, value)

@always_inline 
fn remove(inout row: Row[Datum], key: String):
    for i in range(len(row.data)):
        if row.data[i].key == key:
            for j in range(i + 1, len(row.data)):
                row.data[j - 1] = row.data[j]
            let tmp = row.data.pop_back()
            return 

@always_inline 
fn insert(inout row: Row[Datum], datum: Datum):
    for i in range(len(row.data)):
        if row.data[i].key == datum.key:
            row.data[i] = datum
            return 

    # TODO: might be a bug here
    row.data.push_back(datum)

fn part2(patterns: DynamicVector[String]):
    var boxes = DynamicVector[Row[Datum]]()
    for i in range(256):
        boxes.push_back(Row[Datum]())
    for i in range(len(patterns)):
        let cur_pattern = patterns[i]

        let info = get_info(cur_pattern)
        let hash = part1_hash(info.key)
        print(info.key, info.value, hash)
        if info.value == -1:
            remove(boxes[hash], info.key)
        else:
            insert(boxes[hash], info)

    var answer_p2 = 0
    for i in range(256):
        let cur_box = boxes[i]
        for j in range(len(cur_box.data)):
            answer_p2 += (i + 1) * (j + 1) * cur_box.data[j].value

    print("Part2:", answer_p2)

fn main() raises:
    # NOTE: Does not work due to bu in dynamic vector?
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        let patterns = lines.split(",")
        part1(patterns)
        part2(patterns)