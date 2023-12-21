@always_inline
fn get_horizontal_reflections(rows: DynamicVector[String], smudges: Int = 0) -> DynamicVector[Int]:
    let R = len(rows)
    let C = len(rows[0])
    var answer = DynamicVector[Int]()
    for upper_row_start in range(R - 1):
        var upper_row = upper_row_start
        var lower_row = upper_row + 1 

        var num_smudges = 0 
        while upper_row >= 0 and lower_row < R and num_smudges <= smudges:
            for c in range(C):
                if (rows[upper_row][c] != rows[lower_row][c]):
                    num_smudges += 1

            upper_row -= 1
            lower_row += 1 

        if num_smudges == smudges:
            answer.push_back(upper_row_start)

    return answer 

@always_inline
fn get_vertical_reflections(rows: DynamicVector[String], smudges: Int = 0) -> DynamicVector[Int]:
    let R = len(rows)
    let C = len(rows[0])
    var answer = DynamicVector[Int]()
    for left_col_start in range(C - 1):
        var left_col = left_col_start
        var right_col = left_col + 1 

        var num_smudges = 0 
        while left_col >= 0 and right_col < C and num_smudges <= smudges:
            for r in range(R):
                if rows[r][left_col] != rows[r][right_col]:
                    num_smudges += 1

            left_col -= 1
            right_col += 1 

        if num_smudges == smudges:
            answer.push_back(left_col_start)

    return answer 

fn part1_and_part2(patterns: DynamicVector[String]) raises:
    var answer_p1 = 0
    var answer_p2 = 0
    for i in range(len(patterns)):
        let rows = patterns[i].split("\n")
        let answer_horz1 = get_horizontal_reflections(rows)
        let answer_vert1 = get_vertical_reflections(rows)
        
        for j in range(len(answer_horz1)):
            answer_p1 += (answer_horz1[j] + 1) * 100
        for j in range(len(answer_vert1)):
            answer_p1 += (answer_vert1[j] + 1)

        let answer_horz2 = get_horizontal_reflections(rows, 1)
        let answer_vert2 = get_vertical_reflections(rows, 1)
        
        for j in range(len(answer_horz2)):
            answer_p2 += (answer_horz2[j] + 1) * 100
        for j in range(len(answer_vert2)):
            answer_p2 += (answer_vert2[j] + 1)

    print("Part1:", answer_p1)
    print("Part2:", answer_p2)

fn main() raises:
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        let patterns = lines.split("\n\n")
        part1_and_part2(patterns)