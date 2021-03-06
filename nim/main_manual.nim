import random

type
  NodeObj = object
    x, y: int32
    left, right: Node
  Node = ptr NodeObj

proc destroy(self: Node) {.inline.} =
  if not self.isNil:
    if not self.left.isNil:
      destroy self.left
      self.left = nil
    if not self.right.isNil:
      destroy self.right
      self.right = nil

    dealloc self

proc createNode(x: int32): Node {.noinit, inline.} =
  result = create NodeObj
  result.x = x
  result.y = int32 rand(high int32)

proc merge(lower, greater: Node, res: var Node) =
  if lower.isNil:
    res = greater
  elif greater.isNil:
    res = lower
  elif lower.y < greater.y:
    res = lower
    merge(lower.right, greater, lower.right)
  else:
    res = greater
    merge(lower, greater.left, greater.left)

template merge(lower, equal, greater: Node, res: var Node) =
  merge(lower, equal, res)
  merge(res, greater, res)

proc splitBinary(orig: Node, lower, equalGreater: var Node, value: int32) =
  if orig.isNil:
    lower = nil
    equalGreater = nil
  elif orig.x < value:
    lower = orig
    splitBinary(lower.right, lower.right, equalGreater, value)
  else:
    equalGreater = orig
    splitBinary(equalGreater.left, lower, equalGreater.left, value)

template split(orig: Node, value: int32, lower, equal, greater: var Node) =
  var equalGreater: Node
  splitBinary(orig, lower, equalGreater, value)
  splitBinary(equalGreater, equal, greater, value + 1)

type Tree = object
  root: Node

proc destroy(self: var Tree) =
  destroy self.root
  self.root = nil

template hasValue(self: var Tree, x: int32): bool =
  var lower, equal, greater: Node
  split(self.root, x, lower, equal, greater)
  let ret = not equal.isNil
  merge(lower, equal, greater, self.root)
  ret

template insert(self: var Tree, x: int32) =
  var lower, equal, greater: Node
  split(self.root, x, lower, equal, greater)
  if equal.isNil:
    equal = createNode(x)
  merge(lower, equal, greater, self.root)

template erase(self: var Tree, x: int32) =
  var lower, equal, greater: Node
  split(self.root, x, lower, equal, greater)
  merge(lower, greater, self.root)
  if not equal.isNil:
    destroy equal

proc main() =
  randomize()
  var
    tree = Tree()
    cur = 5'i32
    res = 0'i32

  for i in 1'i32 ..< 1000000'i32:
    let a = i mod 3
    cur = (cur * 57 + 43) mod 10007
    case a:
    of 0:
      tree.insert(cur)
    of 1:
      tree.erase(cur)
    of 2:
      if tree.hasValue(cur):
        res += 1
    else:
      discard

  stdout.write res
  destroy tree

when isMainModule:
  main()
