from typing import Self

class Range:
    def __init__(self, lower: int, upper: int) -> Self:
        self.lower = lower
        self.upper = upper

    def __repr__(self) -> str:
        return f"Range({self.lower}-{self.upper})"

    @staticmethod
    def from_string(string: str) -> Self:
        lower, upper = map(int, string.strip().split("-"))
        return Range(lower, upper)

    def __contains__(self: Self, other: Self) -> bool:
        return self.lower <= other.lower and self.upper >= other.upper

    def __lt__(self: Self, other: Self) -> bool:
        if self.lower < other.lower:
            return True
        if self.lower > other.lower:
            return False
        # same lower bound
        return self.upper < other.upper

    def overlaps(self: Self, other: Self) -> bool:
        r1, r2 = min(self, other), max(self, other)
        return r1.upper >= r2.lower

    def is_valid(self) -> bool:
        return self.lower <= self.upper

    def num_ids(self) -> int:
        return self.upper - self.lower + 1

class RangeList:
    def __init__(self) -> Self:
        self.ranges = []

    def __len__(self: Self) -> int:
        return len(self.ranges)

    def __repr__(self) -> str:
        return f"RangeList({repr(self.ranges)})"

    def num_ids(self) -> int:
        self.simplify()
        return sum(r.num_ids() for r in self.ranges)


    def simplify(self) -> Self:
        if len(self) == 0:
            return self
        self.ranges.sort()
        new_ranges = [self.ranges[0]]
        for r in self.ranges[1:]:
            if new_ranges[-1].upper + 1 == r.lower:
                new_ranges[-1] = Range(new_ranges[-1].lower, r.upper)
            else:
                new_ranges.append(r)
        self.ranges = new_ranges
        return self

    def add(self, my_range: Range) -> Self:
        if len(self) == 0:
            self.ranges.append(my_range)
            return self

        ranges_to_add = [my_range]

        while len(ranges_to_add) > 0:
            my_range = ranges_to_add.pop()
            if not my_range.is_valid():
                # throw away invalid ranges
                continue
            for r in self.ranges:
                if not my_range.overlaps(r):
                    continue
                if my_range in r:
                    my_range.upper = my_range.lower - 1
                    break
                # note they can't be equal now
                if r not in my_range:
                    if r < my_range:
                        my_range.lower = r.upper+1
                    else:
                        my_range.upper = r.lower - 1
                    if not my_range.is_valid():
                        # throw away invalid ranges
                        break
                    continue
                # r is a subset of my_range
                # my_range must be broken into two
                new_range = Range(r.upper+1, my_range.upper)
                if new_range.is_valid():
                    ranges_to_add.append(new_range)
                my_range.upper = r.lower - 1
            if my_range.is_valid():
                self.ranges.append(my_range)

        return self.simplify()




if __name__ == "__main__":
    # rl = RangeList()
    # rl.add(Range(1, 2))
    # rl.add(Range(1, 2))
    # rl.add(Range(2, 4))
    # rl.add(Range(0, 9))
    # rl.add(Range(20, 100))
    # print(rl)

    # file_name = "test_input"
    file_name = "input"
    rl = RangeList()
    ids = []
    with open(file_name, 'r') as f:
        lines = f.readlines()

    for line in lines:
        line = line.strip()
        if "-" in line:
            rl.add(Range.from_string(line))
        elif len(line) > 0:
            ids.append(int(line.strip()))

    # print(rl)
    print(rl.num_ids())
