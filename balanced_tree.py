#!/usr/bin/env python

import pprint

class Node:
  def __init__(self, key, data):
    self.key = key
    self.data = data
    self.left = None
    self.right = None
    self.height = 0
  
  def determine_height(self):
    count_l = (self.left.determine_height() + 1 if self.left else 0)
    count_r = (self.right.determine_height() + 1 if self.right else 0)
    
    self.height = (count_l if count_l > count_r else count_r)
    
    return self.height
  
  def add(self, node):
    if node.key < self.key:
      if self.left == None:
        self.left = node
      else:
        self.left.add(node)
    else:
      if self.right == None:
        self.right = node
      else:
        self.right.add(node)
    
    node.determine_height()
    self.determine_height()
  
  def to_string(self):
    left = 'L:'+self.left.to_string() if self.left != None else ''
    right = 'R:'+self.right.to_string() if self.right != None else ''
    
    return '( {left} {key}[{height}]:"{data}" {right} )'.format(left=left,right=right,key=self.key,data=self.data,height=self.height)
  
  def move_left(self):
    _r = self.right
    _rl = _r.left
    
    self.right = _rl
    _r.left = self
    
    self.determine_height()
    _r.determine_height()
    
    return _r
  
  def move_right(self):
    _l = self.left
    _ll = _l.left
    
    self.left = _ll
    _l.right = self
    
    self.determine_height()
    _l.determine_height()
    
    return _l
  
  def rotate_left(self):
    

def main():
  a = Node(50, 'fifty')
  b = Node(60, 'sixty')
  c = Node(20, 'twenty')
  d = Node(30, 'thirty')
  e = Node(10, 'ten')
  f = Node(5, 'five')
  a.add(b)
  a.add(c)
  a.add(d)
  a.add(e)
  a.add(f)
  
  print(a.to_string())

if __name__ == '__main__':
  main()