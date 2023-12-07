let FIVE_OF_KIND = 6
let FOUR_OF_KIND = 5
let FULL_HOUSE = 4
let THREE_OF_KIND = 3
let TWO_PAIR = 2
let ONE_PAIR = 1
let HIGH_CARD = 0

# Map hands (which are base 13 encoded nums) to the hand type
fn get_type_from_hand_p1(hand: Int) -> Int:
    let card5 = hand % 13 
    let card4 = (hand // 13) % 13
    let card3 = (hand // 13 // 13) % 13
    let card2 = (hand // 13 // 13 // 13) % 13
    let card1 = (hand // 13 // 13 // 13 // 13) % 13

    var cnts = StaticIntTuple[13]()
    for i in range(13):
        cnts[i] = 0
    cnts[card5] += 1
    cnts[card4] += 1
    cnts[card3] += 1
    cnts[card2] += 1
    cnts[card1] += 1

    # parities[n] how many n-pairs there are
    var parities = StaticIntTuple[6]()
    for i in range(6):
        parities[i] = 0
    for i in range(13):
        parities[cnts[i]] += 1
    return get_type_from_parity(parities)

fn get_type_from_parity(parities: StaticIntTuple[6]) -> Int:
    if parities[5] > 0:
        return FIVE_OF_KIND
    elif parities[4] > 0:
        return FOUR_OF_KIND
    elif parities[3] > 0 and parities[2] > 0:
        return FULL_HOUSE
    elif parities[3] > 0:
        return THREE_OF_KIND
    elif parities[2] > 1:
        return TWO_PAIR
    elif parities[2] > 0:
        return ONE_PAIR
    else:
        return HIGH_CARD

# A hand + bid collection
struct Datum(CollectionElement):
    # 2 -> 0, 3 -> 1, T -> 8, A -> 12
    # Then we interpret 32T3K as a base 13 number
    var hand: Int 

    # How much was bid
    var bid: Int 

    # E.g. HIGH_CARD, ONE_PAIR, etc...
    var type: Int 

    fn __init__(inout self, hand: Int, bid: Int):
        self.hand = hand 
        self.bid = bid 
        self.type = get_type_from_hand_p1(hand)

    fn __copyinit__(inout self, existing: Self):
        self.hand = existing.hand
        self.bid = existing.bid
        self.type = existing.type

    fn __moveinit__(inout self, owned existing: Self):
        self.__copyinit__(existing)

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
fn card_to_num(one_char: String) -> Int:
    if one_char == "T":
        return 8
    if one_char == 'J':
        return 9
    if one_char == "Q":
        return 10
    if one_char == "K":
        return 11 
    if one_char == "A":
        return 12 
    return get_digit(one_char) - 2

fn parse_data(data: String) -> DynamicVector[Datum]:
    var answer = DynamicVector[Datum]()
    var i = 0
    while i < len(data):
        var parsing_hand = True 
        var cur_hand = 0
        var cur_bid = 0
        while data[i] != "\n" and i < len(data):
            if data[i] == " ":
                parsing_hand = False 
            elif parsing_hand:
                let card = card_to_num(data[i])
                cur_hand = cur_hand * 13 + card 
            else:
                let digit = get_digit(data[i])
                cur_bid = cur_bid * 10 + digit 
            i += 1 

        answer.push_back(Datum(cur_hand, cur_bid))
        i += 1
    return answer 

struct SortState(CollectionElement):
    # range to sort over 
    var l_bound: Int 
    var r_bound: Int 

    # index 0 == lsb
    var bit_index: Int

    fn __init__(inout self, l_bound: Int, r_bound: Int, bit_index: Int):
        self.l_bound = l_bound 
        self.r_bound = r_bound 
        self.bit_index = bit_index 

    fn __copyinit__(inout self, existing: Self):
        self.l_bound = existing.l_bound 
        self.r_bound = existing.r_bound 
        self.bit_index = existing.bit_index 

    fn __moveinit__(inout self, owned existing: Self):
        self.__copyinit__(existing)

# Binary radix sort cause why not
fn sort_data(inout data: DynamicVector[Datum]):
    var work = DynamicVector[SortState]()

    @parameter
    fn _sort_data_inner[tie_break: Bool](
        inout data: DynamicVector[Datum], 
        state: SortState
    ):
        var fringe = state.l_bound
        var i = state.l_bound
        while i <= state.r_bound:
            let n = data[i].hand if tie_break else data[i].type
            if ((n >> state.bit_index) & 1) == 0:
                let tmp = data[fringe]
                data[fringe] = data[i]
                data[i] = tmp 
                fringe += 1
            i += 1

        let left_new_l_bound = state.l_bound
        let left_new_r_bound = fringe - 1
        if state.bit_index > 0 and left_new_l_bound <= left_new_r_bound:
            work.push_back(
                SortState(left_new_l_bound, left_new_r_bound, state.bit_index - 1)
            )

        let right_new_l_bound = fringe 
        let right_new_r_bound = state.r_bound 
        if state.bit_index > 0 and right_new_l_bound <= right_new_r_bound:
            work.push_back(
                SortState(right_new_l_bound, right_new_r_bound, state.bit_index - 1)
            )

    @parameter 
    fn _sort_data[tie_break: Bool](
        inout data: DynamicVector[Datum], 
        initial_state: SortState
    ):
        work.push_back(initial_state)
        while len(work) > 0:
            let cur_state = work.pop_back()

            # _sort_data may append additional work to work
            _sort_data_inner[tie_break](data, cur_state)

    # First sort by type (largest type is '6' which is 110)
    _sort_data[False](data, SortState(0, len(data) - 1, 2))

    # Then sort by card size within same hands 
    var left_bound = 0
    for i in range(0, len(data)):
        if data[i].type != data[left_bound].type:
            # largest value for hand is 371293 = 13 ^ 5 which takes 18 bits at most
            _sort_data[True](data, SortState(left_bound, i - 1, 18))
            left_bound = i
    _sort_data[True](data, SortState(left_bound, len(data) - 1, 18))

fn part1(data: DynamicVector[Datum]):
    var data_copy = data 
    sort_data(data_copy)

    var answer = 0
    for i in range(len(data_copy)):
        answer += (i + 1) * data_copy[i].bid 
    print("Part1:", answer)

fn repair_datum_inplace_p2(inout datum: Datum):
    ## Handle hands 
    let old_hand = datum.hand  
    let card5 = old_hand % 13 
    let card4 = (old_hand // 13) % 13
    let card3 = (old_hand // 13 // 13) % 13
    let card2 = (old_hand // 13 // 13 // 13) % 13
    let card1 = (old_hand // 13 // 13 // 13 // 13) % 13
        
    # short for "(r)emap-(c)ard"
    @always_inline
    fn rc(old_card: Int) -> Int:
        if old_card > 9: # Q, K, A
            return old_card
        if old_card == 9: # J
            return 0 
        return old_card + 1 # 2, 3, ... 9, T

    let new_hand = rc(card1) * 13 * 13 * 13 * 13 + 
                   rc(card2) * 13 * 13 * 13 +
                   rc(card3) * 13 * 13 +
                   rc(card4) * 13 +
                   rc(card5)

    ## Handle types
    var cnts = StaticIntTuple[13]()
    for i in range(13):
        cnts[i] = 0
    cnts[rc(card5)] += 1
    cnts[rc(card4)] += 1
    cnts[rc(card3)] += 1
    cnts[rc(card2)] += 1
    cnts[rc(card1)] += 1

    # parities[n] how many n-pairs there are
    var parities = StaticIntTuple[6]()
    for i in range(6):
        parities[i] = 0

    # Don't count parity of jokers
    for i in range(1, 13):
        parities[cnts[i]] += 1

    let num_jokers = cnts[0]

    # Always best to put joker in highest parity 
    for p in range(5, -1, -1):
        if parities[p] == 0:
            continue 

        parities[p] -= 1
        parities[p + num_jokers] += 1
        break

    let new_type = get_type_from_parity(parities)

    datum.hand = new_hand 
    datum.type = new_type 

fn part2(data: DynamicVector[Datum]):
    var data_copy = data 
    for i in range(len(data_copy)):
        repair_datum_inplace_p2(data_copy[i])
    sort_data(data_copy)

    var answer = 0
    for i in range(len(data_copy)):
        answer += (i + 1) * data_copy[i].bid 
    print("Part2:", answer)

fn main() raises:
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        let data = parse_data(lines)
        part1(data)
        part2(data)