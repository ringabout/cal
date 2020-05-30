type 
  Stack*[T] = ref object
    container*: seq[T] 

  CycleArray*[T] = ref object
    list: seq[T]
    size: int
    pos: int


proc len*[T](s: Stack[T]): int =
    s.container.len

proc push*[T](s: Stack[T], elem: T) = 
  s.container.add(elem)

proc pop*[T](s: Stack[T]): T =
  s.container.pop()

proc top*[T](s: Stack[T]): T =
  if s.len > 0:
    result = s.container[s.len - 1]

proc initCycleArray*[T](size:int = 5, 
      pos:int = 0): CycleArray[T] = 
  CycleArray[T](list: @[], size: size, pos:pos)

proc push*[T](s: CycleArray[T], elem: T) = 
  if s.pos < s.list.len:
    s.list[s.pos] = elem
  else: 
    s.list.add(elem)
  s.pos = (s.pos + 1) %% s.size

proc pop*[T](s: CycleArray[T]): T =
  discard

proc top*[T](s: CycleArray[T]): T = 
  s.list[s.pos]

iterator items*[T](s: CycleArray[T]): T =
  for item in s.list:
    yield item
