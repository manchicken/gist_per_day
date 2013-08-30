#!/usr/bin/env python

import unittest

class Node:
  def __init__(self, key, data):
    self.key = key
    self.data = data
    self.left = None
    self.right = None
    self.height = 0
  
  def determine_height(self):
    count_l = (self.left.determine_height() + 1 if self.left != None else 0)
    count_r = (self.right.determine_height() + 1 if self.right != None else 0)
    
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
    
    return self.balance()
  
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
    _lr = _l.right
    
    self.left = _lr
    _l.right = self
    
    self.determine_height()
    _l.determine_height()
    
    return _l
  
  def rotate_left(self):
    _r = self.right
    
    _lH = _r.height if _r.left != None else 0
    _rH = _r.height if _r.right != None else 0
    
    if _lH > _rH: self.right = _r.move_right()
    
    return self.move_left()
  
  def rotate_right(self):
    _l = self.left
    
    _lH = _l.height if _l.left != None else 0
    _rH = _l.height if _l.right != None else 0
    
    if _rH > _lH: self.left = _l.move_left()
    
    return self.move_right()
  
  def balance(self):
    if self.left == None and self.right == None: return self
    
    _lH = self.left.height if self.left != None else 0
    _rH = self.right.height if self.right != None else 0
    
    if _lH + 1 < _rH:
      return self.rotate_left()
    elif _rH + 1 < _lH:
      return self.rotate_right()
    
    self.determine_height()
    return self

class Tester(unittest.TestCase):
  def test_balanced_inserts(self):
    a = Node(50, 'fifty')
    b = Node(60, 'sixty')
    c = Node(20, 'twenty')
    d = Node(30, 'thirty')
    e = Node(10, 'ten')
    f = Node(5, 'five')
    a = a.add(b)
    a = a.add(c)
    a = a.add(d)
    a = a.add(e)
    a = a.add(f)
    
    print(a.to_string())
    
    # These tests verify the integrity of the whole tree
    self.assertEqual(a.data, 'twenty')
    self.assertEqual(a.height, 2)
    self.assertEqual(a.left.data, 'ten')
    self.assertEqual(a.left.height, 1)
    self.assertEqual(a.left.left.data, 'five')
    self.assertEqual(a.left.left.height, 0)
    self.assertEqual(a.left.left.left, None)
    self.assertEqual(a.left.right, None)
    self.assertEqual(a.right.data, 'fifty')
    self.assertEqual(a.right.height, 1)
    self.assertEqual(a.right.left.data, 'thirty')
    self.assertEqual(a.right.left.height, 0)
    self.assertEqual(a.right.left.left, None)
    self.assertEqual(a.right.left.right, None)
    self.assertEqual(a.right.right.data, 'sixty')
    self.assertEqual(a.right.right.height, 0)
    self.assertEqual(a.right.right.left, None)
    self.assertEqual(a.right.right.right, None)

if __name__ == '__main__': unittest.main()


