class Morse{
static const Map<String,List<bool>> characters = {
  'a': [false, true],
  'b': [true, false, false, false],
  'c': [true, false, true, false],
  'd': [true, false, false],
  'e': [false],
  'f': [false, false, true, false],
  'g': [true, true, false],
  'h': [false, false, false, false],
  'i': [false, false],
  'j': [false, true, true, true],
  'k': [true, false, true],
  'l': [false, true, false, false],
  'm': [true, true],
  'n': [true, false],
  'o': [true, true, true],
  'p': [false, true, true, false],
  'q': [true, true, false, true],
  'r': [false, true, false],
  's': [false, false, false],
  't': [true],
  'u': [false, false, true],
  'v': [false, false, false, true],
  'w': [false, true, true],
  'x': [true, false, false, true],
  'y': [true, false, true, true],
  'z': [true, true, false, false],
  '0': [true, true, true, true, true],
  '1': [false, true, true, true, true],
  '2': [false, false, true, true, true],
  '3': [false, false, false, true, true],
  '4': [false, false, false, false, true],
  '5': [false, false, false, false, false],
  '6': [true, false, false, false, false],
  '7': [true, true, false, false, false],
  '8': [true, true, true, false, false],
  '9': [true, true, true, true, false],
  '.': [false, true, false, true, false, true],
  ',': [true, true, false, false, true, true],
  '?': [false, false, true, true, false, false],
  '\'': [false, true, true, true, true, false],
  '!': [true, false, true, false, true, true],
  '/': [true, false, false, true, false],
  '(': [true, false, true, true, false],
  ')': [true, false, true, true, false, true],
  '&': [false, true, false, false, false],
  ':': [true, true, true, false, false, false],
  ';': [true, false, true, false, true, false],
  '=': [true, false, false, false, true],
  '+': [false, true, false, true, false],
  '-': [true, false, false, false, false, true],
  '_': [false, false, true, true, false, true],
  '"': [false, true, false, false, true, false],
  '\$': [false, false, false, true, false, false, true],
  '@': [false, true, true, false, true, false],
};
}
class MChar{
  int blocks;
  bool isOn;
  MChar(this.isOn,this.blocks);
}
//Durations:
//long: 3 blocks
//short: 1 block
//between signals in char: 1 block
//between chars: 3 blocks
//between words: 7 blocks