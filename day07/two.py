import numpy as np
from typing import Generator, Self


SPACE = "."
SPLITER = "^"
START = "S"
BEAM = "|"


Beam = np.ndarray[int]


class TachyonManifoldLayer:
    def __init__(self, chars: str):
        self.spliters = np.array([c == SPLITER for c in chars], dtype=bool)

    def focus(self, beam: Beam) -> Beam:
        new_beam = np.zeros_like(beam, dtype=int)
        for i, count in enumerate(beam):
            if self.spliters[i]:
                new_beam[i-1] += count
                new_beam[i+1] += count
            else:
                new_beam[i] += count
        return new_beam

    def print(self, beam: Beam):
        chars = np.array(['.'] * len(self.spliters))
        chars[:] = SPACE
        chars[self.spliters] = SPLITER
        chars[beam > 0] = BEAM
        return "".join(chars)


class TachyonManifold:
    def __init__(self, lines: list[str]):
        self.start = np.array([c == START for c in lines[0]], dtype=bool)
        self.layers = [TachyonManifoldLayer(line) for line in lines[1:]]
        self.width = self.layers[0].spliters.size

    def focus(self) -> Beam:
        beam = self.start
        for layer in self.layers:
            beam = layer.focus(beam)
        return beam


if __name__ == "__main__":

    # file_name = 'test_input'
    file_name = 'input'

    with open(file_name, 'r') as f:
        lines = [line.strip() for line in f.readlines()]

    tm = TachyonManifold(lines)

    num_timelines = np.sum(tm.focus())
    print(num_timelines)
