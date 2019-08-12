import os, osproc
import parseutils
import sets
import strformat
import strutils
import tables

import cal/utils


let symbols = ["^", "%", "+", "-", "*", "/", "(", ")"].toHashSet
var priority = {"(": 0, "^": 3, "%": 3, "*": 2, "/": 2, "+": 1, "-": 1}.newTable
let reserved_set = ["exit", "history"].toHashSet


# type 
#   SymbolError = ref object of Exception
#   ExitError = ref object of Exception

# 微信公众号：Nim编程
proc welcome() =
  stdout.write("Welcome to cal v0.1\nauthor:flywind\n\n")


proc read(prompt: string = "cal> "): string = 
  stdout.write(fmt"{prompt}")
  stdout.flushFile()
  result = stdin.readLine()

iterator token(expressions: string): string = 
  var sentences: string = expressions
  for symbol in symbols:
    sentences = sentences.replace(symbol, fmt" {symbol} ") 
  var temp: seq[string]
  for sentence in sentences.split:
    if sentence != "":
      temp.add(sentence)
  var target: seq[string] = temp
  for (i, item) in temp.pairs:
    if item == "-": 
      if (i-1) < 0 or temp[i-1] == "(": 
        target[i] = ""
        target[i+1] = fmt"-{target[i+1]}"
    if target[i] != "":
      yield target[i]

    

proc comparePriority(first: string, second: string): bool = 
  let f_priority: int = priority[first]
  let s_priority: int = priority[second]
  return f_priority <= s_priority

proc isFloat(num: string): bool = 
  try:
    discard parseFloat(num)
    return true
  except ValueError:
    return false


proc parseInfix(expressions: string): seq[string] = 
  var s: Stack[string] = Stack[string](container: @[])
  var target: seq[string] = @[]
  for expression in token(expressions):
    let flag = (expression in symbols)
    if not isFloat(expression) and not flag:
      raise newException(ValueError, "error")

    if isFloat(expression):
      target.add(expression)

    elif expression == ")":
      while s.top != "(": 
        target.add(s.pop)
      discard s.pop

    elif expression == "(":
      s.push(expression)

    elif s.top != "" and comparePriority(expression, s.top):
      target.add(s.pop)
      while s.top != "" and comparePriority(expression, s.top):
        target.add(s.pop)
      s.push(expression)
    else:
      s.push(expression)

  while s.len != 0:
    target.add(s.pop)
  result = target


proc evaluate(symbol: string, num1: float, num2: float): float =
  if symbol == "+":
    return num1 + num2
  elif symbol == "-":
    return num1 - num2
  elif symbol == "*":
    return num1 * num2
  elif symbol == "/":
    try:
      return num1 / num2
    except DivByZeroError:
      stdout.write("除数不可以为零")
  # elif symbol == "^":
  #   return num1 ** num2
  # elif symbol == "%":
  #   return num1 %% num2


proc parseSufix(expressions: seq[string]): float =
  var target: float
  var s: Stack[string] = Stack[string](container: @[])
  for expression in expressions:
    if isFloat(expression):
      s.push(expression)
    else:
      var elem2 = parseFloat(s.pop)
      var elem1 = parseFloat(s.pop)
      target = evaluate(expression, elem1, elem2)
      s.push(fmt"{target}")
  if s.len > 0:
    target = parseFloat(s.pop)
  result = target 


proc parse(sentence: string): float = 
  let expr_infix: seq[string] = parseInfix(sentence)
  let value: float = parseSufix(expr_infix)
  return value


proc reversed_op(operator: string, history: CycleArray[string]): bool = 
  result = true
  if operator == "exit":
    result = false
  elif operator == "history":
    stdout.write("********************\n")
    for item in history.items:
      stdout.write(fmt"{item}")
      stdout.write("\n")
    stdout.write("********************\n")

proc loop() =
  welcome()
  var running = true
  var history = initCycleArray[string]() 
  while running:
    var target: string = read().strip()
    if target in reserved_set:
      running = reversed_op(target, history)
      continue
   
    try:
      var eval_value: float = parse(target)   
      stdout.write(fmt"{eval_value}")
      stdout.write("\n")
      history.push(target)       
    except ValueError:
      stdout.write("ilegal expression, rewrite\n")
    except OverflowError:
      stdout.write("too large\n")
    except:
      stdout.write("rewrite\n")
  stdout.write("see you later!")


proc main() = 
  loop()



main()
  

