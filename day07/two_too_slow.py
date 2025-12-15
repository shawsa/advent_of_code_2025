import numpy as np
from typing import Generator, Self


SPACE = "."
SPLITER = "^"
START = "S"
BEAM = "|"


Beam = np.ndarray[bool]


class TachyonManifoldLayer:
    def __init__(self, chars: str):
        self.spliters = np.array([c == SPLITER for c in chars], dtype=bool)
        self.active = self.spliters & ~self.spliters

    def focus(self, beam: Beam) -> Beam:
        self.active = self.spliters & beam
        new_beam = beam & ~self.active
        new_beam[:-1] |= self.active[1:]
        new_beam[1:] |= self.active[:-1]
        return new_beam

    def print(self, beam: Beam):
        chars = np.array(['.'] * len(self.spliters))
        chars[:] = SPACE
        chars[self.spliters] = SPLITER
        chars[beam] = BEAM
        return "".join(chars)


class TachyonManifold:
    def __init__(self, lines: list[str]):
        self.start = np.array([c == START for c in lines[0]], dtype=bool)
        self.layers = [TachyonManifoldLayer(line) for line in lines[1:]]
        self.width = self.layers[0].spliters.size


class Timeline:
    def __init__(self, tm: TachyonManifold, ids: list[int] | None = None):
        self.tm = tm
        if ids is not None:
            self.ids = ids
        else:
            self.ids = [np.argmax(tm.start)]

    def beam(self, index: int, size: int) -> Beam:
        beam = np.zeros(size, dtype=bool)
        beam[index] = True
        return beam

    def print(self) -> str:
        return "\n".join(layer.print(self.beam(index, tm.width))
                         for index, layer in zip(self.ids, self.tm.layers))

    def generate(self) -> Generator[Self, None, None]:
        if len(self.ids) == len(self.tm.layers):
            yield self
            return
        index = self.ids[-1]
        layer = self.tm.layers[len(self.ids)]
        if not layer.spliters[index]:
            self.ids.append(index)
            yield from self.generate()
        else:
            right = Timeline(tm, self.ids + [index+1])
            self.ids.append(index-1)
            yield from self.generate()
            yield from right.generate()


if __name__ == "__main__":

    file_name = 'test_input'
    # file_name = 'input'

    with open(file_name, 'r') as f:
        lines = [line.strip() for line in f.readlines()]

    tm = TachyonManifold(lines)

    for index, timeline in enumerate(Timeline(tm).generate()):
        print(timeline.print())
        print(f"{index}\n")

    num_timelines = sum(1 for _ in Timeline(tm).generate())
    print(num_timelines)
