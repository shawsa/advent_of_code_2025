import numpy as np


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


if __name__ == "__main__":

    # file_name = 'test_input'
    file_name = 'input'

    with open(file_name, 'r') as f:
        lines = [line.strip() for line in f.readlines()]

    tm = TachyonManifold(lines)

    beam = np.array([c == 'S' for c in lines[0]], dtype=bool)

    for layer in tm.layers:
        beam = layer.focus(beam)
        # print(layer.print(beam))

    activated = sum(np.sum(layer.active) for layer in tm.layers)

    print(activated)
