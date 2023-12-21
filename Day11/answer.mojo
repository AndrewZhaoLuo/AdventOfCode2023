from math import abs 
fn part1_and_2(data: DynamicVector[String], expansion_factor: Int) -> Int:
    let R = len(data)
    let C = len(data[0])

    # grab empty rows and columns
    var empty_rows = DynamicVector[Int]()
    for r in range(R):
        var isEmpty = True 
        for c in range(C):
            isEmpty = data[r][c] == "."
            if not isEmpty:
                break
        if isEmpty:
            empty_rows.push_back(r)

    var empty_cols = DynamicVector[Int]()
    for c in range(C):
        var isEmpty = True 
        for r in range(R):
            isEmpty = data[r][c] == "."
            if not isEmpty:
                break
        if isEmpty:
            empty_cols.push_back(c)

    # prefix sums of distances 
    var total_distance_rows = DynamicVector[Int]()
    var empty_row_i = 0
    var last_row_value = 0
    for r in range(R):
        if empty_row_i < len(empty_rows) and r == empty_rows[empty_row_i]:
            empty_row_i += 1
            total_distance_rows.push_back(last_row_value + expansion_factor)
        else:
            total_distance_rows.push_back(last_row_value + 1)
        last_row_value = total_distance_rows[total_distance_rows.size - 1]

    var total_distance_cols = DynamicVector[Int]()
    var empty_col_i = 0
    var last_col_value = 0
    for c in range(C):
        if empty_col_i < len(empty_cols) and c == empty_cols[empty_col_i]:
            empty_col_i += 1
            total_distance_cols.push_back(last_col_value + expansion_factor)
        else:
            total_distance_cols.push_back(last_col_value + 1)
        last_col_value = total_distance_cols[total_distance_cols.size - 1]

    # tuple is (r, c)
    var galaxies = DynamicVector[Tuple[Int, Int]]()
    for r in range(R):
        for c in range(C):
            if data[r][c] == "#":
                galaxies.push_back((r, c))

    var answer = 0
    for i in range(len(galaxies)):
        for j in range(i + 1, len(galaxies)):
            let p1 = galaxies[i]
            let p2 = galaxies[j]

            let r1 = p1.get[0, Int]()
            let c1 = p1.get[1, Int]()

            let r2 = p2.get[0, Int]()
            let c2 = p2.get[1, Int]()

            let distance_local = abs(total_distance_rows[r1] - total_distance_rows[r2]) +
                                 abs(total_distance_cols[c1] - total_distance_cols[c2])
            answer += distance_local
    return answer

fn main() raises:
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        let data = lines.split("\n")
        print("Part1:", part1_and_2(data, 2))
        print("Part2_example1:", part1_and_2(data, 10))
        print("Part2_example2:", part1_and_2(data, 100))
        print("Part2:", part1_and_2(data, 1000000))